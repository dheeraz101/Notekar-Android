import os
import re
import glob

mapping = {
    'add': 'add_rounded',
    'app_badge': 'notifications_rounded',
    'arrow_down_doc_fill': 'file_download_rounded',
    'arrow_down_left': 'south_west_rounded',
    'arrow_up': 'arrow_upward_rounded',
    'arrow_up_arrow_down': 'swap_vert_rounded',
    'arrow_up_right': 'north_east_rounded',
    'bolt_horizontal_circle': 'electric_bolt_rounded',
    'book_fill': 'menu_book_rounded',
    'calendar': 'calendar_today_rounded',
    'camera_fill': 'camera_alt_rounded',
    'car_fill': 'directions_car_rounded',
    'check_mark': 'check_rounded',
    'check_mark_circled': 'check_circle_outline_rounded',
    'checkmark': 'check_rounded',
    'checkmark_circle_fill': 'check_circle_rounded',
    'checkmark_seal_fill': 'verified_rounded',
    'chevron_back': 'chevron_left_rounded',
    'chevron_down': 'keyboard_arrow_down_rounded',
    'chevron_forward': 'chevron_right_rounded',
    'chevron_right': 'chevron_right_rounded',
    'chevron_up': 'keyboard_arrow_up_rounded',
    'circle': 'circle_outlined',
    'circle_grid_hex': 'grid_view_rounded',
    'clock': 'access_time_rounded',
    'compass_fill': 'explore_rounded',
    'device_laptop': 'laptop_mac_rounded',
    'doc_checkmark_fill': 'fact_check_rounded',
    'doc_on_clipboard': 'content_paste_rounded',
    'doc_text': 'description_rounded',
    'doc_text_fill': 'description_rounded',
    'drop_fill': 'water_drop_rounded',
    'ellipsis_circle': 'more_horiz_rounded',
    'ellipsis_vertical_circle': 'more_vert_rounded',
    'exclamationmark_shield': 'security_rounded',
    'eye_fill': 'visibility_rounded',
    'flag': 'flag_rounded',
    'flag_circle': 'flag_circle_rounded',
    'flag_fill': 'flag_rounded',
    'flame': 'local_fire_department_rounded',
    'flame_fill': 'local_fire_department_rounded',
    'gamecontroller_fill': 'sports_esports_rounded',
    'gear_alt': 'settings_rounded',
    'hand_draw_fill': 'draw_rounded',
    'heart_circle_fill': 'favorite_rounded',
    'heart_fill': 'favorite_rounded',
    'hourglass': 'hourglass_bottom_rounded',
    'info': 'info_outline_rounded',
    'line_horizontal_3_decrease_circle': 'filter_list_rounded',
    'line_horizontal_3_decrease_circle_fill': 'filter_list_rounded',
    'link': 'link_rounded',
    'list_bullet': 'format_list_bulleted_rounded',
    'lock_shield_fill': 'gpp_good_rounded',
    'minus': 'remove_rounded',
    'moon_fill': 'dark_mode_rounded',
    'moon_stars_fill': 'bedtime_rounded',
    'moon_zzz': 'bedtime_rounded',
    'news': 'article_rounded',
    'paintbrush': 'brush_rounded',
    'pause_fill': 'pause_rounded',
    'person_2_fill': 'people_rounded',
    'person_fill': 'person_rounded',
    'play_arrow_solid': 'play_arrow_rounded',
    'plus': 'add_rounded',
    'plus_app': 'add_box_rounded',
    'plus_bubble': 'add_comment_rounded',
    'plus_circle': 'add_circle_outline_rounded',
    'plus_circle_fill': 'add_circle_rounded',
    'quote_bubble': 'format_quote_rounded',
    'radiowaves_right': 'rss_feed_rounded',
    'scope': 'track_changes_rounded',
    'search': 'search_rounded',
    'selection_pin_in_out': 'adjust_rounded',
    'settings': 'settings_rounded',
    'share': 'share_rounded',
    'shield_fill': 'security_rounded',
    'slider_horizontal_3': 'tune_rounded',
    'sparkles': 'auto_awesome_rounded',
    'speaker_2_fill': 'volume_up_rounded',
    'square_pencil': 'edit_rounded',
    'stop_fill': 'stop_rounded',
    'suit_club_fill': 'park_rounded',
    'sun_max_fill': 'light_mode_rounded',
    'sunrise_fill': 'wb_twilight_rounded',
    'sunset_fill': 'wb_twilight_rounded',
    'tag_fill': 'label_rounded',
    'time': 'schedule_rounded',
    'timelapse': 'timelapse_rounded',
    'trash': 'delete_rounded',
    'wind': 'air_rounded',
    'xmark': 'close_rounded',
}

files = glob.glob('lib/**/*.dart', recursive=True)
for file_path in files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # If it uses CupertinoIcons, we must ensure material.dart is imported, but usually it is.
    original = content
    for cup, mat in mapping.items():
        content = re.sub(r'CupertinoIcons\.' + cup + r'\b', f'Icons.{mat}', content)

    if original != content:
        # Also clean up the import if it exists
        content = re.sub(r"import 'package:flutter/cupertino\.dart' show CupertinoIcons;\n?", "", content)
        content = re.sub(r"import 'package:flutter/cupertino\.dart';\n?", "", content)
        
        # Make sure material is imported if we just removed cupertino
        if "import 'package:flutter/material.dart';" not in content:
            # add it after the first import
            content = re.sub(r"(import .*?;)", r"\1\nimport 'package:flutter/material.dart';", content, count=1)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
print("Icons swapped!")
