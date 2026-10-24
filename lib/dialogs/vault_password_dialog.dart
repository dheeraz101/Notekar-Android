import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';

enum VaultPasswordMode { encrypt, decrypt }

class VaultPasswordDialog extends StatefulWidget {
  const VaultPasswordDialog({super.key, required this.p, required this.mode});

  final Palette p;
  final VaultPasswordMode mode;

  static Future<String?> show({
    required BuildContext context,
    required Palette p,
    bool isExport = false,
    VaultPasswordMode? mode,
  }) {
    final effectiveMode =
        mode ??
        (isExport ? VaultPasswordMode.encrypt : VaultPasswordMode.decrypt);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VaultPasswordDialog(p: p, mode: effectiveMode),
    );
  }

  @override
  State<VaultPasswordDialog> createState() => _VaultPasswordDialogState();
}

class _VaultPasswordDialogState extends State<VaultPasswordDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final password = _passwordController.text;
    if (password.length < 4) {
      setState(() {
        _errorMessage = 'Password must be at least 4 characters.';
      });
      HapticFeedback.heavyImpact();
      return;
    }

    if (widget.mode == VaultPasswordMode.encrypt) {
      final confirm = _confirmController.text;
      if (password != confirm) {
        setState(() {
          _errorMessage = 'Passwords do not match.';
        });
        HapticFeedback.heavyImpact();
        return;
      }
    }

    HapticFeedback.selectionClick();
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final isEncrypt = widget.mode == VaultPasswordMode.encrypt;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: AppSheet(
        p: p,
        title: isEncrypt ? 'Encrypt Sovereign Vault' : 'Unlock Sovereign Vault',
        showLargeTitle: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isEncrypt ? p.accent : p.orange).withValues(
                      alpha: 0.15,
                    ),
                  ),
                  child: Icon(
                    isEncrypt
                        ? CupertinoIcons.lock_shield_fill
                        : CupertinoIcons.lock_open_fill,
                    color: isEncrypt ? p.accent : p.orange,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isEncrypt
                    ? 'Your personal moments are encrypted using zero-knowledge PBKDF2 + AES-256-GCM. NoteKar never stores or transmits this password.'
                    : 'Enter the master password used to encrypt this .notekar-vault backup file.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.border.withValues(alpha: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: TextField(
                  key: const ValueKey('vault_password_input'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofocus: true,
                  style: TextStyle(color: p.text, fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter vault password',
                    hintStyle: TextStyle(color: p.text3),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        color: p.text3,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  onSubmitted: (_) {
                    if (!isEncrypt) _handleSubmit();
                  },
                ),
              ),
              if (isEncrypt) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.border.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: TextField(
                    key: const ValueKey('vault_password_confirm_input'),
                    controller: _confirmController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: p.text, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Confirm vault password',
                      hintStyle: TextStyle(color: p.text3),
                    ),
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.red,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: p.text2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        key: const ValueKey('vault_password_submit_btn'),
                        style: FilledButton.styleFrom(
                          backgroundColor: isEncrypt ? p.accent : p.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _handleSubmit,
                        child: Text(
                          isEncrypt ? 'Encrypt & Export' : 'Unlock & Restore',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
