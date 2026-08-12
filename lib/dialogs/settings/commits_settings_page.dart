import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommitsSettingsPage extends StatefulWidget {
  const CommitsSettingsPage({
    super.key,
    required this.p,
    required this.enableTranslucency,
    required this.reduceMotion,
  });

  final Palette p;
  final bool enableTranslucency;
  final bool reduceMotion;

  @override
  State<CommitsSettingsPage> createState() => _CommitsSettingsPageState();
}

class _CommitsSettingsPageState extends State<CommitsSettingsPage> {
  final _updateService = UpdateService();
  List<Map<String, dynamic>>? _commits;
  bool _loadingCommits = false;
  String? _commitsError;
  int _visibleCount = 10;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initAndLoadCache();
  }

  Future<void> _initAndLoadCache() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final cachedStr = _prefs?.getString('notekar.cached_commits');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final decoded = _deserializeCommits(cachedStr);
        if (decoded.isNotEmpty && mounted) {
          setState(() {
            _commits = decoded;
          });
        }
      }
    } catch (_) {}
    _fetchCommits();
  }

  String _serializeCommits(List<Map<String, dynamic>> commits) {
    final list = commits.map((c) {
      return {
        'sha': c['sha'],
        'message': c['message'],
        'author': c['author'],
        'date': (c['date'] as DateTime?)?.toIso8601String(),
      };
    }).toList();
    return jsonEncode(list);
  }

  List<Map<String, dynamic>> _deserializeCommits(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is List) {
      return decoded
          .map((c) {
            if (c is Map) {
              final dateStr = c['date'] as String?;
              return {
                'sha': c['sha'] as String? ?? '',
                'message': c['message'] as String? ?? '',
                'author': c['author'] as String? ?? '',
                'date': dateStr != null ? DateTime.tryParse(dateStr) : null,
              };
            }
            return <String, dynamic>{};
          })
          .where((m) => m.isNotEmpty)
          .toList();
    }
    return [];
  }

  Future<void> _fetchCommits({bool isManualRefresh = false}) async {
    if (mounted) {
      setState(() {
        _loadingCommits = true;
      });
    }
    try {
      final list = await _updateService.fetchRecentCommits();
      if (mounted) {
        setState(() {
          if (list != null && list.isNotEmpty) {
            _commits = list;
            _commitsError = null;
          } else if (_commits == null || _commits!.isEmpty) {
            _commitsError =
                'No internet connection. Connect to load latest activity.'
                    .localized(context);
          }
          _loadingCommits = false;
        });
      }
      if (list != null && list.isNotEmpty) {
        final cacheList = list.take(10).toList();
        await _prefs?.setString(
          'notekar.cached_commits',
          _serializeCommits(cacheList),
        );
      } else if (isManualRefresh && mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No Internet Connection. Showing cached preview.'.localized(
                context,
              ),
            ),
            backgroundColor: widget.p.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_commits == null || _commits!.isEmpty) {
            _commitsError =
                'No internet connection. Connect to load latest activity.'
                    .localized(context);
          }
          _loadingCommits = false;
        });
        if (isManualRefresh) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No Internet Connection. Showing cached preview.'.localized(
                  context,
                ),
              ),
              backgroundColor: widget.p.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _onRefresh() {
    setState(() {
      _visibleCount = 10;
    });
    _fetchCommits(isManualRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    if (_loadingCommits && (_commits == null || _commits!.isEmpty)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: const CupertinoActivityIndicator(radius: 14),
        ),
      );
    }
    if (_commits == null || _commits!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.commit_rounded, color: p.accent, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'No Repository Activity'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _commitsError ??
                    'Connect to the internet to load the latest repository activity.'
                        .localized(context),
                textAlign: TextAlign.center,
                style: TextStyle(color: p.text3, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              PressableScale(
                onTap: _loadingCommits ? null : _onRefresh,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_loadingCommits)
                        const CupertinoActivityIndicator(
                          color: Colors.white,
                          radius: 7,
                        )
                      else
                        const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        'Check Again'.localized(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final shownCount = math.min(_visibleCount, _commits!.length);
    final hasMore = _commits!.length > shownCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.center,
          child: PressableScale(
            onTap: _loadingCommits ? null : _onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: p.accent.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loadingCommits)
                    const CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 8,
                    )
                  else
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    'Refresh Activity'.localized(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_commitsError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: p.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.red.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: p.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Offline: Showing cached activity. Try refreshing again later.'
                        .localized(context),
                    style: TextStyle(
                      color: p.red,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...List.generate(shownCount, (index) {
              final commit = _commits![index];
              final sha = commit['sha'] as String;
              final shortSha = sha.length > 7 ? sha.substring(0, 7) : sha;
              final msg = commit['message'] as String;
              final author = commit['author'] as String;
              final date = commit['date'] as DateTime?;

              String timeAgo = '';
              if (date != null) {
                final diff = DateTime.now().difference(date);
                if (diff.inDays > 0) {
                  timeAgo = '${diff.inDays}d ago';
                } else if (diff.inHours > 0) {
                  timeAgo = '${diff.inHours}h ago';
                } else {
                  timeAgo = '${diff.inMinutes}m ago';
                }
              }

              return Container(
                key: ValueKey(sha),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.commit_rounded,
                        color: p.accent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                author,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: p.surface3,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  shortSha,
                                  style: TextStyle(
                                    color: p.text3,
                                    fontSize: 9.5,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeAgo,
                                style: TextStyle(color: p.text3, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            msg,
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              );
            }),
            if (hasMore)
              PressableScale(
                onTap: () {
                  setState(() {
                    if (_visibleCount == 10) {
                      _visibleCount = 30;
                    } else if (_visibleCount == 30) {
                      _visibleCount = 60;
                    } else {
                      _visibleCount = 100;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 60,
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: p.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Show More'.localized(context),
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Showing $shownCount of ${_commits!.length} commits'.localized(
              context,
            ),
            style: TextStyle(
              color: p.text3,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
