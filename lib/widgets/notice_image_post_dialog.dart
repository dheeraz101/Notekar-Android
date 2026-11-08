import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:notekar/l10n/app_localizations.dart';
import 'package:notekar/models/app_notice.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/network_logger.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Full-screen Apple HIG / iOS-style Notice Image Post Viewer.
///
/// Features:
/// - Top bar: "Notice" title with Cupertino close ('X') frosted circle button.
/// - Full-screen interactive image canvas supporting 9:16 portrait, 16:9 landscape,
///   and arbitrary aspect ratios with smooth fit and letterboxing.
/// - Pinch-to-zoom and double-tap zoom animation.
/// - Bottom bar: Apple HIG-styled "Save to Gallery" action button that downloads
///   and saves the image to the device gallery with graceful permission handling.
class NoticeImagePostDialog extends StatefulWidget {
  const NoticeImagePostDialog({
    super.key,
    required this.p,
    this.notice,
    this.imageUrl,
    this.title = 'Notice',
    this.subtitle,
    this.aspectRatio,
    this.initialBytes,
  });

  final Palette p;
  final AppNotice? notice;
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final String? aspectRatio;
  final Uint8List? initialBytes;

  /// Displays the full-screen Notice Image Post dialog with Cupertino transition.
  static Future<void> show(
    BuildContext context, {
    required Palette p,
    AppNotice? notice,
    String? imageUrl,
    String title = 'Notice',
    String? subtitle,
    String? aspectRatio,
    Uint8List? initialBytes,
  }) {
    HapticFeedback.lightImpact();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss notice',
      barrierColor: Colors.black.withValues(alpha: 0.94),
      transitionDuration: const Duration(milliseconds: 240),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (_, _, _) => NoticeImagePostDialog(
        p: p,
        notice: notice,
        imageUrl: imageUrl ?? notice?.imageUrl,
        title: title,
        subtitle: subtitle ?? notice?.localizedTitle(context),
        aspectRatio: aspectRatio ?? notice?.aspectRatio,
        initialBytes: initialBytes,
      ),
    );
  }

  @override
  State<NoticeImagePostDialog> createState() => _NoticeImagePostDialogState();
}

class _NoticeImagePostDialogState extends State<NoticeImagePostDialog>
    with SingleTickerProviderStateMixin {
  final _logger = AppLogger();

  late final TransformationController _transformationController;
  late final AnimationController _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;

  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  bool _isSaving = false;
  bool _isSaved = false;
  String? _saveStatusMessage;

  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _zoomAnimationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          if (_zoomAnimation != null) {
            _transformationController.value = _zoomAnimation!.value;
          }
        });

    if (widget.initialBytes != null) {
      _imageBytes = widget.initialBytes;
      _isLoading = false;
    } else {
      _loadImage();
    }
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  String _resolveLanguageCode() {
    final rawLocale = AppLocalizations.of(context)?.localeName ?? 'en';
    return rawLocale.split('_').first.toLowerCase();
  }

  String _localizedText(String key) {
    final lang = _resolveLanguageCode();
    switch (key) {
      case 'notice':
        return switch (lang) {
          'hi' => 'सूचना',
          'es' => 'Aviso',
          'de' => 'Hinweis',
          'fr' => 'Avis',
          'ja' => 'お知らせ',
          'ru' => 'Уведомление',
          _ => 'Notice',
        };
      case 'saveToGallery':
        return switch (lang) {
          'hi' => 'गैलरी में सहेजें',
          'es' => 'Guardar en galería',
          'de' => 'In Galerie speichern',
          'fr' => 'Enregistrer dans la galerie',
          'ja' => 'ギャラリーに保存',
          'ru' => 'Сохранить в галерею',
          _ => 'Save to Gallery',
        };
      case 'savedToGallery':
        return switch (lang) {
          'hi' => 'गैलरी में सहेजा गया',
          'es' => 'Guardado en la galería',
          'de' => 'In Galerie gespeichert',
          'fr' => 'Enregistré dans la galerie',
          'ja' => 'ギャラリーに保存しました',
          'ru' => 'Сохранено в галерею',
          _ => 'Saved to Gallery',
        };
      case 'saving':
        return switch (lang) {
          'hi' => 'सहेजा जा रहा है...',
          'es' => 'Guardando...',
          'de' => 'Wird gespeichert...',
          'fr' => 'Enregistrement...',
          'ja' => '保存中...',
          'ru' => 'Сохранение...',
          _ => 'Saving...',
        };
      case 'unableToLoad':
        return switch (lang) {
          'hi' => 'सूचना छवि लोड करने में असमर्थ',
          'es' => 'No se pudo cargar la imagen del aviso',
          'de' => 'Hinweisbild konnte nicht geladen werden',
          'fr' => 'Impossible de charger l\'image de l\'avis',
          'ja' => 'お知らせの画像を読み込めません',
          'ru' => 'Не удалось загрузить изображение уведомления',
          _ => 'Unable to load notice image',
        };
      case 'checkConnection':
        return switch (lang) {
          'hi' => 'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें',
          'es' => 'Comprueba tu conexión a internet e inténtalo de nuevo',
          'de' => 'Bitte Internetverbindung prüfen und erneut versuchen',
          'fr' => 'Veuillez vérifier votre connexion internet et réessayer',
          'ja' => 'インターネット接続を確認して再試行してください',
          'ru' => 'Проверьте подключение к интернету и повторите попытку',
          _ => 'Check your internet connection and try again',
        };
      case 'retry':
        return switch (lang) {
          'hi' => 'पुनः प्रयास करें',
          'es' => 'Reintentar',
          'de' => 'Wiederholen',
          'fr' => 'Réessayer',
          'ja' => '再試行',
          'ru' => 'Повторить',
          _ => 'Retry',
        };
      case 'failedToSave':
        return switch (lang) {
          'hi' => 'गैलरी में सहेजने में विफल',
          'es' => 'Error al guardar en galería',
          'de' => 'Fehler beim Speichern in der Galerie',
          'fr' => 'Échec de l\'enregistrement dans la galerie',
          'ja' => 'ギャラリーへの保存に失敗しました',
          'ru' => 'Не удалось сохранить в галерею',
          _ => 'Failed to save to gallery',
        };
      default:
        return key;
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    final url = widget.imageUrl ?? widget.notice?.imageUrl;
    if (url == null || url.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No image URL provided';
        });
      }
      return;
    }

    try {
      // 1. Direct asset path check
      if (url.startsWith('assets/') ||
          url.startsWith('notice_image/') ||
          url.startsWith('screenshot/')) {
        try {
          final assetData = await rootBundle.load(url);
          if (mounted) {
            setState(() {
              _imageBytes = assetData.buffer.asUint8List(
                assetData.offsetInBytes,
                assetData.lengthInBytes,
              );
              _isLoading = false;
            });
          }
          return;
        } catch (_) {}
      }

      // 2. Direct local file path check
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        final localFile = File(url);
        if (localFile.existsSync()) {
          final bytes = await localFile.readAsBytes();
          if (mounted) {
            setState(() {
              _imageBytes = bytes;
              _isLoading = false;
            });
          }
          return;
        }
      }

      // 3. Remote HTTPS fetch
      if (url.startsWith('http://') || url.startsWith('https://')) {
        try {
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 8));

          await NetworkLogger.log(
            url: url,
            method: 'GET',
            statusCode: response.statusCode,
            purpose: 'Notice Image Asset Download',
            size: response.bodyBytes.isNotEmpty
                ? '${(response.bodyBytes.lengthInBytes / 1024).toStringAsFixed(2)} KB'
                : 'Unknown',
          );

          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            if (mounted) {
              setState(() {
                _imageBytes = response.bodyBytes;
                _isLoading = false;
              });
            }
            return;
          }
        } catch (netErr) {
          _logger.warn('Remote image fetch failed for $url: $netErr');
        }
      }

      // 4. Local asset & bundled fallback
      final uri = Uri.tryParse(url);
      final fileName = uri != null && uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : '';

      if (fileName.isNotEmpty) {
        // Try bundled asset under notice_image/
        try {
          final assetData = await rootBundle.load('notice_image/$fileName');
          if (mounted) {
            setState(() {
              _imageBytes = assetData.buffer.asUint8List(
                assetData.offsetInBytes,
                assetData.lengthInBytes,
              );
              _isLoading = false;
            });
          }
          return;
        } catch (_) {}

        // Try bundled asset under screenshot/
        try {
          final assetData = await rootBundle.load('screenshot/$fileName');
          if (mounted) {
            setState(() {
              _imageBytes = assetData.buffer.asUint8List(
                assetData.offsetInBytes,
                assetData.lengthInBytes,
              );
              _isLoading = false;
            });
          }
          return;
        } catch (_) {}

        // Try bundled asset under assets/images/
        try {
          final assetData = await rootBundle.load('assets/images/$fileName');
          if (mounted) {
            setState(() {
              _imageBytes = assetData.buffer.asUint8List(
                assetData.offsetInBytes,
                assetData.lengthInBytes,
              );
              _isLoading = false;
            });
          }
          return;
        } catch (_) {}

        // Try relative local file paths
        final candidateFiles = [
          File('notice_image/$fileName'),
          File('screenshot/$fileName'),
          File('assets/images/$fileName'),
          File('../notice_image/$fileName'),
          File(fileName),
        ];
        for (final cand in candidateFiles) {
          if (cand.existsSync()) {
            final bytes = await cand.readAsBytes();
            if (mounted) {
              setState(() {
                _imageBytes = bytes;
                _isLoading = false;
              });
            }
            return;
          }
        }
      }

      throw HttpException(
        'Unable to load notice image from $url or local bundled fallback',
      );
    } catch (e, stack) {
      _logger.warn('Failed to load notice image from $url: $e', e, stack);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onDoubleTap() {
    if (_zoomAnimationController.isAnimating) return;

    final isCurrentlyZoomed =
        _transformationController.value.getMaxScaleOnAxis() > 1.05;
    final beginMatrix = _transformationController.value;
    final endMatrix = isCurrentlyZoomed
        ? Matrix4.identity()
        : () {
            final position = _doubleTapDetails?.localPosition ?? Offset.zero;
            final matrix = Matrix4.identity();
            matrix.setEntry(0, 0, 2.5);
            matrix.setEntry(1, 1, 2.5);
            matrix.setEntry(0, 3, -position.dx * 1.5);
            matrix.setEntry(1, 3, -position.dy * 1.5);
            return matrix;
          }();

    _zoomAnimation = Matrix4Tween(begin: beginMatrix, end: endMatrix).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _zoomAnimationController.forward(from: 0.0);
  }

  Future<void> _saveToGallery() async {
    if (_isSaving || _imageBytes == null) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isSaving = true;
      _saveStatusMessage = null;
    });

    try {
      final noticeId = widget.notice?.id ?? 'notice';
      final cleanId = noticeId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      // Detect correct MIME type and file extension from bytes and URL
      String mimeType = 'image/jpeg';
      String ext = 'jpg';
      final bytes = _imageBytes!;
      if (bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        mimeType = 'image/png';
        ext = 'png';
      } else if (bytes.length >= 12 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46) {
        mimeType = 'image/webp';
        ext = 'webp';
      } else {
        final urlLower = (widget.imageUrl ?? widget.notice?.imageUrl ?? '')
            .toLowerCase();
        if (urlLower.endsWith('.png')) {
          mimeType = 'image/png';
          ext = 'png';
        } else if (urlLower.endsWith('.webp')) {
          mimeType = 'image/webp';
          ext = 'webp';
        }
      }

      final fileName =
          'notekar_${cleanId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final savedUri = await MediaStorageService.instance.saveImageToGallery(
        bytes: _imageBytes!,
        fileName: fileName,
        mimeType: mimeType,
      );

      if (mounted) {
        if (savedUri != null && savedUri.isNotEmpty) {
          AppHaptics.confirm();
          setState(() {
            _isSaving = false;
            _isSaved = true;
            _saveStatusMessage = _localizedText('savedToGallery');
          });
        } else {
          HapticFeedback.heavyImpact();
          setState(() {
            _isSaving = false;
            _saveStatusMessage = _localizedText('failedToSave');
          });
        }
      }
    } catch (e, stack) {
      _logger.error('Failed saving notice image to gallery: $e', e, stack);
      if (mounted) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isSaving = false;
          _saveStatusMessage = _localizedText('failedToSave');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final notice = widget.notice;

    final displayTitle = widget.title == 'Notice'
        ? _localizedText('notice')
        : widget.title;

    final noticeHeading = notice?.localizedTitle(context) ?? widget.subtitle;
    final noticeBody = notice?.localizedBody(context);

    // Calculate aspect ratio constraint if specified
    final numericRatio = notice?.numericAspectRatio;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Main Interactive Image Canvas
          GestureDetector(
            onDoubleTapDown: (details) => _doubleTapDetails = details,
            onDoubleTap: _onDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              clipBehavior: Clip.none,
              child: Center(child: _buildImageContent(p, numericRatio)),
            ),
          ),

          // 2. Top Bar: Apple HIG "Notice" Title & Cupertino ('X') Close Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.bell_fill,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            displayTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (notice != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: notice.isCritical
                                    ? p.red
                                    : (notice.isFeature ? p.blue : p.text3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notice.badgeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Cupertino Close ('X') Icon Button
                    PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 0.8,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Action Bar: Notice Caption & Apple HIG "Save to Gallery" Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Optional Notice Caption / Context Card
                    if (noticeHeading != null && noticeHeading.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              noticeHeading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (noticeBody != null &&
                                noticeBody.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                noticeBody,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                    // Status Toast Banner (e.g. "Saved to Gallery")
                    if (_saveStatusMessage != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isSaved
                              ? const Color(0xFF34C759)
                              : const Color(0xFFFF3B30),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isSaved
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons
                                        .exclamationmark_triangle_fill,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _saveStatusMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Bottom Apple HIG "Save to Gallery" Button
                    PressableScale(
                      onTap: (_isLoading || _hasError || _isSaving)
                          ? null
                          : _saveToGallery,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: _isSaved
                              ? const Color(0xFF34C759)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSaving
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CupertinoActivityIndicator(
                                      radius: 9,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _localizedText('saving'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isSaved
                                          ? CupertinoIcons.checkmark_alt
                                          : CupertinoIcons.arrow_down_to_line,
                                      size: 19,
                                      color: _isSaved
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isSaved
                                          ? _localizedText('savedToGallery')
                                          : _localizedText('saveToGallery'),
                                      style: TextStyle(
                                        color: _isSaved
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(Palette p, double? numericRatio) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoActivityIndicator(radius: 14, color: Colors.white),
            SizedBox(height: 14),
            Text(
              'Loading Notice...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError || _imageBytes == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.wifi_exclamationmark,
              size: 40,
              color: Color(0xFFFF9500),
            ),
            const SizedBox(height: 14),
            Text(
              _localizedText('unableToLoad'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _localizedText('checkConnection'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 18),
            PressableScale(
              onTap: _loadImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 15,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _localizedText('retry'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget imageWidget = Image.memory(
      _imageBytes!,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          _localizedText('unableToLoad'),
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );

    // If an explicit aspect ratio (such as 9:16 or 16:9) is given, wrap in AspectRatio with squircle corners
    if (numericRatio != null && numericRatio > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(aspectRatio: numericRatio, child: imageWidget),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageWidget,
      ),
    );
  }
}
