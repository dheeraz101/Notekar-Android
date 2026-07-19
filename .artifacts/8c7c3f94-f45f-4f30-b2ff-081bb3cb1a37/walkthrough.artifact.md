# Settings Cleanup & Link Update Walkthrough

I have updated the project's external links and streamlined the main Settings page for a cleaner, more minimalist appearance.

## 🔗 Link & Email Updates
The following production-ready details have been integrated:
- **Buy me a Coffee**: Updated to `https://buymeacoffee.com/dheeraz`
- **Support Email**: Updated to `yabp.support@gmail.com`

## 🧹 Main Settings UI Cleanup
I have removed the dynamic status values (like "Locked", "124 Logs", "Fast") from the **main settings root list**.
- **Cleaner Aesthetics**: The root settings now look like a professional, simplified menu.
- **Consistent Info**: Status information remains available inside each specific sub-category (e.g., Theme name inside Personalization, or performance details inside Device Health).

## ✅ Verification Results
- **Link Accuracy**: Confirmed the Buy me a Coffee and Support Email constants are correctly updated in `app_utils.dart`.
- **UI Integrity**: Verified that the root settings rows no longer show trailing status text.
- **Test Suite**: All unit and widget tests passed successfully.
