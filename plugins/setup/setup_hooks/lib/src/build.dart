import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'build_cache.dart';
import 'concord_builder.dart';
import 'error.dart';
import 'fingerprint.dart';
import 'options.dart';
import 'rust_builder.dart';
import 'target.dart';
import 'util.dart';

final _log = Logger('setup_hooks');

class BuildRequest {
  const BuildRequest({
    required this.rootDir,
    required this.target,
    this.harnessDir,
  });

  final String rootDir;
  final Target target;

  final String? harnessDir;
}

class BuildReport {
  const BuildReport({
    required this.inputs,
    required this.outputs,
    required this.rebuilt,
  });

  final List<String> inputs;
  final List<String> outputs;
  final bool rebuilt;

  /// A directory dependency hashes child names, not content, so a deleted
  /// artifact still reruns the hook without rereading the Core.
  List<String> get outputDirectories =>
      {for (final output in outputs) p.dirname(output)}.toList()..sort();
}

/// The Helper embeds the Core's SHA256, so the Core is built first.
Future<BuildReport> buildPlatform(BuildRequest request) async {
  final stopwatch = Stopwatch()..start();
  final target = request.target;
  final rootDir = request.rootDir;
  final config = BuildConfig.load(rootDir: rootDir);
  final patch = p.join(rootDir, 'patches', 'concord-customizations.patch');
  final hasPatch = File(patch).existsSync();
  if (hasPatch) {
    _applyConcordPatch(p.join(rootDir, config.concordDir), patch);
  }
  final cache = BuildCache(rootDir: rootDir);
  final notice = BuildNotice();
  final harnessInputs = [
    if (request.harnessDir case final dir?) ...collectPackageInputs(dir),
    if (hasPatch) patch,
  ];

  final core = await ConcordBuilder(
    rootDir: rootDir,
    config: config,
    cache: cache,
    notice: notice,
    harnessInputs: harnessInputs,
  ).build(target);
  if (!target.hasHelper) {
    _log.info('Done in ${stopwatch.elapsed}: ${core.primaryOutput}');
    return _report([core]);
  }

  final coreSha256 = await calcSha256(core.primaryOutput);
  final helper = await RustBuilder(
    rootDir: rootDir,
    config: config,
    cache: cache,
    notice: notice,
    harnessInputs: harnessInputs,
  ).build(target, coreSha256);
  final manifestPath = p.join(
    rootDir,
    config.outputDir,
    target.platformDir,
    coreManifestName,
  );
  writeCoreManifest(path: manifestPath, coreSha256: coreSha256);

  _log.info(
    'Done in ${stopwatch.elapsed}: ${core.primaryOutput}, '
    '${helper.primaryOutput}',
  );
  return _report([core, helper], extraOutputs: [manifestPath]);
}

void _applyConcordPatch(String directory, String patch) {
  final reversed = Process.runSync('git', [
    '-C',
    directory,
    'apply',
    '--reverse',
    '--check',
    '--ignore-whitespace',
    patch,
  ]);
  if (reversed.exitCode == 0) return;
  final result = Process.runSync('git', [
    '-C',
    directory,
    'apply',
    '--ignore-whitespace',
    patch,
  ]);
  if (result.exitCode != 0) {
    throw BuildException(
      'Could not apply Concord customizations: ${result.stderr}',
    );
  }
}

BuildReport _report(
  List<BuildExecution> results, {
  List<String> extraOutputs = const [],
}) {
  final inputs = <String>{};
  final outputs = <String>{};
  for (final result in results) {
    inputs.addAll(result.inputs);
    outputs.addAll(result.outputs);
  }
  outputs.addAll(extraOutputs);
  return BuildReport(
    inputs: inputs.toList()..sort(),
    outputs: outputs.toList()..sort(),
    rebuilt: results.any((result) => result.rebuilt),
  );
}
