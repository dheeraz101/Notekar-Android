// Sobriety Milestone Data
//
// 21 milestones from 1 to 3650 days (10 years), all rooted in addiction
// neuroscience, PAWS research, fMRI studies, and behavioural psychology.
//
// 10 themed name sets give users psychological resonance with their
// own self-narrative style.

library;

class SobrietyMilestone {
  const SobrietyMilestone({
    required this.days,
    required this.dayLabel,
    required this.whyItMatters,
  });

  final int days;
  final String dayLabel;
  final String whyItMatters;
}

class ThemedMilestone {
  const ThemedMilestone({required this.name, required this.flavor});

  final String name;

  /// A short, theme-flavoured "why it matters" line.
  final String flavor;
}

class SobrietyMilestoneEntry {
  const SobrietyMilestoneEntry({
    required this.days,
    required this.dayLabel,
    required this.whyItMatters,
    required this.themes,
  });

  final int days;
  final String dayLabel;

  /// Universal neuroscience explanation shown in all themes.
  final String whyItMatters;

  /// Keyed by theme id, returns name + flavour text.
  final Map<String, ThemedMilestone> themes;
}

// ---------------------------------------------------------------------------
// Theme metadata
// ---------------------------------------------------------------------------

class MilestoneTheme {
  const MilestoneTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
}

const List<MilestoneTheme> kMilestoneThemes = [
  MilestoneTheme(
    id: 'science',
    name: 'Science',
    emoji: '🔬',
    description: 'Clinical neuroscience terms. Cold, precise, honest.',
  ),
  MilestoneTheme(
    id: 'warrior',
    name: 'Warrior',
    emoji: '⚔️',
    description: 'Army elite. Every clean day is a battle fought and won.',
  ),
  MilestoneTheme(
    id: 'navy',
    name: 'Navy',
    emoji: '⚓',
    description: 'Seafaring odyssey. Chart new waters and never look back.',
  ),
  MilestoneTheme(
    id: 'clan',
    name: 'Clan',
    emoji: '🏔️',
    description: 'Celtic highland clan. Earn your place, carry the banner.',
  ),
  MilestoneTheme(
    id: 'ancient',
    name: 'Ancient',
    emoji: '🏛️',
    description: 'Greek and Roman glory. Rise from mortal to Olympian.',
  ),
  MilestoneTheme(
    id: 'samurai',
    name: 'Samurai',
    emoji: '🗡️',
    description:
        'Bushido code. The warrior who masters the self is unbeatable.',
  ),
  MilestoneTheme(
    id: 'space',
    name: 'Space',
    emoji: '🚀',
    description: 'Cosmic exploration. Every clean day is light-years gained.',
  ),
  MilestoneTheme(
    id: 'kingdom',
    name: 'Kingdom',
    emoji: '👑',
    description:
        'Medieval royalty. Rise from serf to sovereign through discipline.',
  ),
  MilestoneTheme(
    id: 'monk',
    name: 'Monk',
    emoji: '🙏',
    description: 'Monastic journey. Silence, stillness, and sacred vows.',
  ),
  MilestoneTheme(
    id: 'phoenix',
    name: 'Phoenix',
    emoji: '🔥',
    description:
        'Rebirth through fire. The old self is ash; you are the flame.',
  ),
];

// ---------------------------------------------------------------------------
// The 21 milestones
// ---------------------------------------------------------------------------

const List<SobrietyMilestoneEntry> kSobrietyMilestones = [
  SobrietyMilestoneEntry(
    days: 1,
    dayLabel: '1 Day',
    whyItMatters:
        'Acute withdrawal begins. The body starts clearing toxins within the first 24 hours — the hardest window.',
    themes: {
      'science': ThemedMilestone(
        name: 'First Sunrise',
        flavor: 'Acute toxin clearance begins. Every hour now counts.',
      ),
      'warrior': ThemedMilestone(
        name: 'First March',
        flavor: 'Every long campaign starts with a single step. March.',
      ),
      'navy': ThemedMilestone(
        name: 'Cast Off',
        flavor: 'Lines released, tides turning — the voyage has begun.',
      ),
      'clan': ThemedMilestone(
        name: "Initiate's Oath",
        flavor: 'The oath is sworn before the fire. No turning back.',
      ),
      'ancient': ThemedMilestone(
        name: 'First Rite',
        flavor: 'The sacred rites of purification begin at dawn.',
      ),
      'samurai': ThemedMilestone(
        name: 'Seiza',
        flavor: 'The warrior settles into stillness. The trial begins.',
      ),
      'space': ThemedMilestone(
        name: 'Launch',
        flavor: 'Engines ignite. Mission clock is running.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Serf to Freeman',
        flavor: 'The chains are broken. You walk free for the first time.',
      ),
      'monk': ThemedMilestone(
        name: 'First Vow',
        flavor: 'The vow of abstinence is taken at dawn. The bell rings.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Ash',
        flavor: 'Reduced to ash. The fire has consumed the old self.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 3,
    dayLabel: '3 Days',
    whyItMatters:
        'Physical withdrawal peaks at 72 hours for most substances. Cravings are at their most intense — surviving this is a major neurological victory.',
    themes: {
      'science': ThemedMilestone(
        name: 'Peak Storm',
        flavor:
            'Withdrawal at its worst. Your brain chemistry is fighting back.',
      ),
      'warrior': ThemedMilestone(
        name: 'Fire Baptism',
        flavor: 'The fiercest storms forge the strongest soldiers.',
      ),
      'navy': ThemedMilestone(
        name: 'Open Water',
        flavor: 'Land is gone from view. Fully in open sea.',
      ),
      'clan': ThemedMilestone(
        name: 'Trial by Fire',
        flavor: 'Every clan member faces three days of initiation fire.',
      ),
      'ancient': ThemedMilestone(
        name: 'Trial of Olympus',
        flavor: 'Three ordeals faced by every hero worth legend.',
      ),
      'samurai': ThemedMilestone(
        name: 'First Blood',
        flavor:
            'The blade has been tested against the fiercest enemy — the self.',
      ),
      'space': ThemedMilestone(
        name: 'Escape Velocity',
        flavor: 'Free from the gravity well. No orbit, only forward.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Dungeon Survivor',
        flavor: 'Three days endured in the mind\'s darkest dungeon.',
      ),
      'monk': ThemedMilestone(
        name: 'Silent Vigil',
        flavor: 'Three days of silence. The mind begins, slowly, to quiet.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Ember',
        flavor: 'A tiny ember glows beneath the ash. Do not let it die.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 7,
    dayLabel: '1 Week',
    whyItMatters:
        'The brain resumes baseline dopamine production after 7 days. The first reward-cycle completes, and mood begins to stabilise.',
    themes: {
      'science': ThemedMilestone(
        name: 'First Week',
        flavor: 'Dopamine baseline restored. The reward system is rebooting.',
      ),
      'warrior': ThemedMilestone(
        name: 'Field Proven',
        flavor: 'A week in the field proves your resolve to your platoon.',
      ),
      'navy': ThemedMilestone(
        name: 'First Storm Past',
        flavor: 'The first storm weathered. Sea legs found.',
      ),
      'clan': ThemedMilestone(
        name: 'Blood Week',
        flavor: 'A week of proving blood ties. The clan watches.',
      ),
      'ancient': ThemedMilestone(
        name: 'Agoge Begins',
        flavor:
            'Seven days; enrolled in the training programme of Spartan warriors.',
      ),
      'samurai': ThemedMilestone(
        name: 'Dojo Accepted',
        flavor: 'Seven days; formally accepted as a student of the dojo.',
      ),
      'space': ThemedMilestone(
        name: 'First Orbit',
        flavor: 'Seven days in space; one full orbit of the Earth complete.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Village Guard',
        flavor:
            'Seven days of service; trusted to stand watch on the village gate.',
      ),
      'monk': ThemedMilestone(
        name: 'Novitiate',
        flavor: 'Seven days; officially enrolled as a novice of the monastery.',
      ),
      'phoenix': ThemedMilestone(
        name: 'First Flame',
        flavor: 'Seven days; the flame catches and holds through the wind.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 14,
    dayLabel: '2 Weeks',
    whyItMatters:
        'REM sleep architecture normalises after 14 days — deep sleep returns. Mood swings reduce significantly as serotonin stabilises.',
    themes: {
      'science': ThemedMilestone(
        name: 'Neural Thaw',
        flavor: 'REM sleep returns. Your brain is thawing from the freeze.',
      ),
      'warrior': ThemedMilestone(
        name: 'FOB Established',
        flavor: 'Forward base secured. Supply lines are running. Dig in.',
      ),
      'navy': ThemedMilestone(
        name: 'Midwatch',
        flavor:
            'The darkest watch before dawn — and you held it without flinching.',
      ),
      'clan': ThemedMilestone(
        name: 'Kinship Bond',
        flavor:
            'Two weeks; kinship bonds are forged in shared struggle and fire.',
      ),
      'ancient': ThemedMilestone(
        name: 'The Forge',
        flavor: 'Two weeks on the forge. The hero is taking shape.',
      ),
      'samurai': ThemedMilestone(
        name: 'Two-Week Strike',
        flavor: 'Form begins taking shape. Muscle memory is awakening.',
      ),
      'space': ThemedMilestone(
        name: 'Adapted to Zero-G',
        flavor: 'Two weeks; the body has fully adjusted to the void.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Town Militia',
        flavor: 'Two weeks; promoted to captain of the town militia.',
      ),
      'monk': ThemedMilestone(
        name: 'Cell Keeper',
        flavor: 'Two weeks; entrusted with keeping a monastic cell in order.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Kindling',
        flavor: 'Two weeks; enough heat to kindle a real and lasting fire.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 21,
    dayLabel: '21 Days',
    whyItMatters:
        'Neural plasticity research identifies 21 days as the threshold where cortical grooves begin rewiring. Old pathways weaken; new ones are forming.',
    themes: {
      'science': ThemedMilestone(
        name: 'Habit Horizon',
        flavor:
            'Cortical rewiring threshold crossed. Old pathways are losing power.',
      ),
      'warrior': ThemedMilestone(
        name: 'Combat Hardened',
        flavor:
            'Three weeks turns a raw recruit into a battle-hardened soldier.',
      ),
      'navy': ThemedMilestone(
        name: 'Steady Bearing',
        flavor: 'Three weeks at sea; course locked, compass true, helm steady.',
      ),
      'clan': ThemedMilestone(
        name: 'Shield Bearer',
        flavor:
            'Three weeks; earned the right to carry the clan\'s sacred shield.',
      ),
      'ancient': ThemedMilestone(
        name: "Oracle's Word",
        flavor: 'Twenty-one days; the Oracle speaks of your destiny.',
      ),
      'samurai': ThemedMilestone(
        name: 'Third Kata',
        flavor: 'Three weeks; mastery of the third form of the kata confirmed.',
      ),
      'space': ThemedMilestone(
        name: 'Module Docked',
        flavor:
            '21 days; docking with the station — mission critical achieved.',
      ),
      'kingdom': ThemedMilestone(
        name: "King's Messenger",
        flavor:
            '21 days; trusted to carry the king\'s messages across the realm.',
      ),
      'monk': ThemedMilestone(
        name: 'Three-Week Retreat',
        flavor: 'The traditional length of a transformative spiritual retreat.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Warming Fire',
        flavor: '21 days; the fire now provides warmth, not just light.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 30,
    dayLabel: '30 Days',
    whyItMatters:
        'The liver completes a full detox cycle. The prefrontal cortex — the seat of willpower — begins measurable structural recovery.',
    themes: {
      'science': ThemedMilestone(
        name: 'One Month',
        flavor:
            'Liver detox complete. Prefrontal cortex structural recovery begins.',
      ),
      'warrior': ThemedMilestone(
        name: 'Tour Launched',
        flavor: 'First full month on active duty. The mission is under way.',
      ),
      'navy': ThemedMilestone(
        name: 'First Port',
        flavor: 'One month at sea — the first harbour in sight. You made it.',
      ),
      'clan': ThemedMilestone(
        name: 'Clan Member',
        flavor: 'Full membership earned after the first full moon cycle.',
      ),
      'ancient': ThemedMilestone(
        name: 'First Games',
        flavor:
            'One month; entered in the first of the Olympian competitive games.',
      ),
      'samurai': ThemedMilestone(
        name: 'Moon Training',
        flavor:
            'One full moon of daily practice without a single missed session.',
      ),
      'space': ThemedMilestone(
        name: 'Lunar Month',
        flavor: 'One full lunar cycle observed from the silence of orbit.',
      ),
      'kingdom': ThemedMilestone(
        name: "Knight's Squire",
        flavor:
            'One month; formally accepted as squire to a Knight of the Realm.',
      ),
      'monk': ThemedMilestone(
        name: 'First Moon Fast',
        flavor:
            'One complete lunar fast — mind and body intact through all of it.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Steady Burn',
        flavor: 'One month; the fire burns steadily without constant tending.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 45,
    dayLabel: '45 Days',
    whyItMatters:
        'Post-Acute Withdrawal Syndrome (PAWS) — the wave of cravings, anxiety and insomnia after physical detox — begins fading noticeably at 45 days.',
    themes: {
      'science': ThemedMilestone(
        name: 'Turning Point',
        flavor: 'PAWS symptoms begin fading. The fog is lifting.',
      ),
      'warrior': ThemedMilestone(
        name: 'Midpoint Patrol',
        flavor:
            'Past the halfway mark; enemy contact reducing. Hold formation.',
      ),
      'navy': ThemedMilestone(
        name: 'Deep Water',
        flavor: 'Past the continental shelf. No shallow water to retreat to.',
      ),
      'clan': ThemedMilestone(
        name: 'Trusted Kin',
        flavor:
            '45 days; the clan begins to trust your counsel in war councils.',
      ),
      'ancient': ThemedMilestone(
        name: 'Laurel of Apollo',
        flavor: '45 days; Apollo grants the first laurel wreath for endurance.',
      ),
      'samurai': ThemedMilestone(
        name: 'Steel Folded',
        flavor: '45 days; the blade has been folded forty times in the forge.',
      ),
      'space': ThemedMilestone(
        name: 'Halfway to Moon',
        flavor: '45 days; the midpoint of a lunar transfer trajectory.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Battlefield Tested',
        flavor:
            '45 days; you have survived the first great battle of the self.',
      ),
      'monk': ThemedMilestone(
        name: 'Inner Stillness',
        flavor: '45 days; the inner noise begins, at last, to fall silent.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Rising Smoke',
        flavor:
            '45 days; the smoke signal of your rebirth is visible for miles.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 60,
    dayLabel: '2 Months',
    whyItMatters:
        'Neuroimaging (fMRI) studies show measurable grey-matter regrowth in the prefrontal cortex at the 60-day mark — physical brain healing you can scan.',
    themes: {
      'science': ThemedMilestone(
        name: 'Two Months',
        flavor:
            'fMRI-detectable grey-matter regrowth. Your brain is rebuilding.',
      ),
      'warrior': ThemedMilestone(
        name: 'Operation Secured',
        flavor:
            'The front line has been held for two full months. Well done, soldier.',
      ),
      'navy': ThemedMilestone(
        name: 'Longitude Marked',
        flavor:
            'Two months; a new longitude charted. You are further than you\'ve ever been.',
      ),
      'clan': ThemedMilestone(
        name: "Elder's Favour",
        flavor:
            'Two months; a clan elder vouches for your strength of character.',
      ),
      'ancient': ThemedMilestone(
        name: "Consul's Recognition",
        flavor:
            'Two months; the Roman Consul formally acknowledges your discipline.',
      ),
      'samurai': ThemedMilestone(
        name: 'Two-Month Zazen',
        flavor:
            'Two months of daily zazen — seated meditation — without exception.',
      ),
      'space': ThemedMilestone(
        name: 'Deep Space',
        flavor: 'Two months; outside cislunar space. No turning back now.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Knight-in-Training',
        flavor: 'Two months; formal knighthood training has officially begun.',
      ),
      'monk': ThemedMilestone(
        name: 'Two Months Practice',
        flavor:
            'Two months of daily prayer, meditation, and practice — unbroken.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Bright Flame',
        flavor:
            'Two months; the flame is bright enough now to guide others through the dark.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 90,
    dayLabel: '90 Days',
    whyItMatters:
        'The clinical gold standard. Most residential treatment programmes are 90 days for a reason: dopamine pathways show visible healing on fMRI at this point.',
    themes: {
      'science': ThemedMilestone(
        name: 'The 90',
        flavor:
            'Clinical gold standard. Dopamine pathways visibly healed on fMRI.',
      ),
      'warrior': ThemedMilestone(
        name: 'Campaign Medal',
        flavor:
            'The 90-day campaign. Awarded only to those who survived the full engagement.',
      ),
      'navy': ThemedMilestone(
        name: 'Far Shore',
        flavor: 'The 90-day crossing. Another coast reached. Chart it.',
      ),
      'clan': ThemedMilestone(
        name: 'War Council',
        flavor: '90 days; invited to sit and speak at the war council fire.',
      ),
      'ancient': ThemedMilestone(
        name: 'Centurion',
        flavor:
            'The 90-day threshold that separates soldiers from centurions. Rise.',
      ),
      'samurai': ThemedMilestone(
        name: 'Ronin No More',
        flavor:
            '90 days; the wandering warrior has found their path and their dojo.',
      ),
      'space': ThemedMilestone(
        name: 'Quarter Year',
        flavor: 'The mission has reached its first major deep-space waypoint.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Knighted',
        flavor: 'The sword touches each shoulder. Rise, Knight of the Realm.',
      ),
      'monk': ThemedMilestone(
        name: 'Professed Monk',
        flavor:
            '90 days; formal profession of monastic vows before the community.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Blazing',
        flavor:
            '90 days; a full blazing fire. Your light is felt from far away.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 100,
    dayLabel: '100 Days',
    whyItMatters:
        'A psychologically powerful round number. Three complete monthly hormonal cycles have passed, reinforcing the psychological identity of "someone who doesn\'t use."',
    themes: {
      'science': ThemedMilestone(
        name: 'Century',
        flavor:
            'Three full monthly cycles. Your brain\'s identity is rewriting itself.',
      ),
      'warrior': ThemedMilestone(
        name: 'Centurion Mark',
        flavor:
            '100 days of unbroken service earns the centurion mark on your record.',
      ),
      'navy': ThemedMilestone(
        name: 'Century League',
        flavor: '100 nautical leagues logged into the ship\'s master ledger.',
      ),
      'clan': ThemedMilestone(
        name: 'Clan Champion',
        flavor: '100 days; named champion of the annual highland gathering.',
      ),
      'ancient': ThemedMilestone(
        name: 'Senate Record',
        flavor: '100 days inscribed in the Roman Senate records of honour.',
      ),
      'samurai': ThemedMilestone(
        name: 'Ink on Scroll',
        flavor: '100 days; the sensei records your name on the honour scroll.',
      ),
      'space': ThemedMilestone(
        name: 'Century Mark',
        flavor:
            'Mission control marks 100 mission days with a ceremony on the ground.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Tournament Champion',
        flavor: '100 days; named champion of the great annual tournament.',
      ),
      'monk': ThemedMilestone(
        name: 'Illuminated',
        flavor:
            '100 days; the light of clarity begins to shine unmistakably from within.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Inferno',
        flavor: '100 days; the inferno of transformation roars at full power.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 180,
    dayLabel: '6 Months',
    whyItMatters:
        'Emotional regulation returns to pre-addiction baseline at 6 months. Anger, anxiety, and impulsivity are measurably reduced. You feel like yourself again.',
    themes: {
      'science': ThemedMilestone(
        name: 'Half Year',
        flavor:
            'Emotional regulation back at baseline. You feel like yourself again.',
      ),
      'warrior': ThemedMilestone(
        name: 'Six-Month Citation',
        flavor: 'Half-year citation for distinguished and unbroken service.',
      ),
      'navy': ThemedMilestone(
        name: 'Equator Crossed',
        flavor:
            'Halfway around the world. Neptune is honoured. The crew celebrates.',
      ),
      'clan': ThemedMilestone(
        name: 'Clan Elder',
        flavor: 'Six months earns the grey sash of the clan elder. Hard-won.',
      ),
      'ancient': ThemedMilestone(
        name: 'Praetor',
        flavor:
            'Six months; promoted to Praetor, administrator of justice in the city.',
      ),
      'samurai': ThemedMilestone(
        name: 'Samurai',
        flavor:
            'Six months earns the title Samurai. You have proven the bushido code lives in you.',
      ),
      'space': ThemedMilestone(
        name: 'ISS Milestone',
        flavor:
            'Six months; the ISS benchmark. Crew health fully adapted to the void.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Baron',
        flavor:
            'Six months; a barony of land granted by the crown. Govern it well.',
      ),
      'monk': ThemedMilestone(
        name: 'Senior Novice',
        flavor:
            'Six months; now guiding newer novices on the path you have walked.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Rebirth Begun',
        flavor: 'Six months; feathers beginning to emerge from the flame.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 270,
    dayLabel: '9 Months',
    whyItMatters:
        '9 months mirrors the gestational period — a full neuroplasticity cycle has completed. Your brain has, in a very real sense, rebuilt itself from scratch.',
    themes: {
      'science': ThemedMilestone(
        name: 'Gestation',
        flavor: 'A full neuroplasticity cycle. Your brain is effectively new.',
      ),
      'warrior': ThemedMilestone(
        name: 'Nine-Month Commendation',
        flavor:
            'Strategic mastery demonstrated across nine gruelling months of deployment.',
      ),
      'navy': ThemedMilestone(
        name: 'Three Quarters Round',
        flavor:
            'Nine months; three-quarters of a full circumnavigation of the globe.',
      ),
      'clan': ThemedMilestone(
        name: 'Keeper of Lore',
        flavor:
            'Nine months; entrusted with the clan\'s oral history. The stories live in you.',
      ),
      'ancient': ThemedMilestone(
        name: "Nine Muses' Gift",
        flavor:
            'Nine months; all nine Muses have bestowed their wisdom upon you.',
      ),
      'samurai': ThemedMilestone(
        name: 'Senior Samurai',
        flavor:
            'Nine months; trusted with guarding the domain lord\'s inner chambers.',
      ),
      'space': ThemedMilestone(
        name: 'Mars Transfer Window',
        flavor: 'Nine months; approaching the Mars transfer orbital window.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Lord Commander',
        flavor:
            'Nine months; commanding the entire castle garrison with full authority.',
      ),
      'monk': ThemedMilestone(
        name: 'Contemplative',
        flavor:
            'Nine months of unbroken contemplative practice. The mind is quiet.',
      ),
      'phoenix': ThemedMilestone(
        name: 'New Wings',
        flavor:
            'Nine months; wings fully formed, ready to unfurl and catch the thermal.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 365,
    dayLabel: '1 Year',
    whyItMatters:
        'A full year means you have experienced every seasonal trigger — holidays, anniversaries, seasons — at least once and stayed clean. PAWS is typically gone.',
    themes: {
      'science': ThemedMilestone(
        name: 'Full Orbit',
        flavor:
            'Every seasonal trigger faced once. PAWS resolved for most at this point.',
      ),
      'warrior': ThemedMilestone(
        name: 'First Tour Complete',
        flavor:
            'Full year of deployment without once breaking ranks. Immovable.',
      ),
      'navy': ThemedMilestone(
        name: 'Circumnavigation',
        flavor:
            'A year at sea; the globe has been rounded once. Your name is in the log.',
      ),
      'clan': ThemedMilestone(
        name: 'High Council',
        flavor:
            'A full year; your seat on the high council is formally secured.',
      ),
      'ancient': ThemedMilestone(
        name: 'Year of the Gods',
        flavor:
            'A full year blessed by all twelve Olympian gods. Favour is with you.',
      ),
      'samurai': ThemedMilestone(
        name: 'Year of the Blade',
        flavor:
            'A full year; the sword is now an extension of the soul itself.',
      ),
      'space': ThemedMilestone(
        name: 'Full Orbit',
        flavor:
            'One complete revolution around the sun. Mission: year one complete.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Count',
        flavor:
            'A full year; elevated to the rank of Count. A territory is yours.',
      ),
      'monk': ThemedMilestone(
        name: 'Year of Grace',
        flavor:
            'A full year of grace. The inner transformation is now complete.',
      ),
      'phoenix': ThemedMilestone(
        name: 'First Flight',
        flavor: 'A year; the Phoenix spreads its wings and takes flight. Soar.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 500,
    dayLabel: '500 Days',
    whyItMatters:
        'Relapse rate drops sharply between year one and year two. At 500 days, research shows most recoveries have crossed into stable long-term remission territory.',
    themes: {
      'science': ThemedMilestone(
        name: '500 Days',
        flavor:
            'Relapse risk drops sharply. Stable long-term remission territory.',
      ),
      'warrior': ThemedMilestone(
        name: 'Iron Cross',
        flavor:
            'Awarded to soldiers who held position across 500 gruelling missions.',
      ),
      'navy': ThemedMilestone(
        name: 'Five Hundred Fathoms',
        flavor: 'Half a thousand days plumbing the deepest waters.',
      ),
      'clan': ThemedMilestone(
        name: "Warchief's Shadow",
        flavor:
            '500 days; you walk in the warchief\'s shadow as most trusted advisor.',
      ),
      'ancient': ThemedMilestone(
        name: 'Consul',
        flavor:
            '500 days; elected to the highest civilian office of the Republic.',
      ),
      'samurai': ThemedMilestone(
        name: 'Kenjutsu Master',
        flavor:
            '500 days; mastery of the complete sword arts is formally recognised.',
      ),
      'space': ThemedMilestone(
        name: 'Asteroid Belt',
        flavor: 'Crossing the asteroid belt into deep space proper.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Marquis',
        flavor: '500 days; governing the borderlands with iron discipline.',
      ),
      'monk': ThemedMilestone(
        name: 'Prior',
        flavor: '500 days; appointed Prior of a small contemplative community.',
      ),
      'phoenix': ThemedMilestone(
        name: 'High Flight',
        flavor:
            '500 days; soaring above the clouds, far above the world below.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 548,
    dayLabel: '18 Months',
    whyItMatters:
        'Research shows PAWS is completely resolved in 95 % of individuals at 18 months. Your baseline brain chemistry is now functionally normal.',
    themes: {
      'science': ThemedMilestone(
        name: 'Year & Half',
        flavor:
            'PAWS resolved in 95 % of cases at this point. Brain chemistry normal.',
      ),
      'warrior': ThemedMilestone(
        name: 'Senior Commando',
        flavor:
            '18 months of elite special operations without a single failure.',
      ),
      'navy': ThemedMilestone(
        name: "Admiral's Citation",
        flavor:
            'Eighteen months earns the Admiral\'s personal and public commendation.',
      ),
      'clan': ThemedMilestone(
        name: 'Guardian of the Hearth',
        flavor: '18 months; guardian of the clan\'s sacred and eternal flame.',
      ),
      'ancient': ThemedMilestone(
        name: 'Hero of Athens',
        flavor:
            '18 months; a bronze statue is erected in your honour in the Athenian agora.',
      ),
      'samurai': ThemedMilestone(
        name: 'Hatamoto',
        flavor:
            '18 months; elevated to direct retainer of the Shogun\'s inner court.',
      ),
      'space': ThemedMilestone(
        name: 'Martian Orbit',
        flavor: '18 months; arriving at Mars. The red planet hangs before you.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Duke',
        flavor:
            '18 months; elevated to Duke — second only to the royal family in power.',
      ),
      'monk': ThemedMilestone(
        name: 'Father Superior',
        flavor:
            'Eighteen months; leading a monastic house as Father or Mother Superior.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Touched the Sun',
        flavor:
            '18 months; like Icarus but stronger — you reached the sun and were not burned.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 730,
    dayLabel: '2 Years',
    whyItMatters:
        'Long-term recovery officially begins at 2 years. Dopamine pathways are fully rebuilt. The Journal of Substance Abuse Treatment classifies 2+ years as the stable recovery phase.',
    themes: {
      'science': ThemedMilestone(
        name: 'Two Years',
        flavor:
            'Long-term recovery phase begins. Dopamine pathways fully rebuilt.',
      ),
      'warrior': ThemedMilestone(
        name: 'Double Tour',
        flavor:
            'Two years of unwavering active service. Double tour. A rare honour.',
      ),
      'navy': ThemedMilestone(
        name: 'Two-Year Voyage',
        flavor:
            'Two years; the great explorers\' standard. You are among the legendary.',
      ),
      'clan': ThemedMilestone(
        name: 'Warchief',
        flavor:
            'Two years; elected to lead the clan in both battle and peacetime.',
      ),
      'ancient': ThemedMilestone(
        name: 'Proconsul',
        flavor:
            'Two years; governing with full proconsular authority over a province.',
      ),
      'samurai': ThemedMilestone(
        name: 'Senior Hatamoto',
        flavor:
            'Two years; senior advisor sitting at the Shogun\'s own court table.',
      ),
      'space': ThemedMilestone(
        name: 'Mars Surface',
        flavor:
            'Two years; first boot prints on Martian soil. History written.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Grand Duke',
        flavor: 'Two years; given a grand duchy. Your legacy is being built.',
      ),
      'monk': ThemedMilestone(
        name: 'Abbot',
        flavor:
            'Two years; elevated to Abbot of the Abbey. The community looks to you.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Full Phoenix',
        flavor:
            'Two years; the complete Phoenix transformation cycle fulfilled.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 1095,
    dayLabel: '3 Years',
    whyItMatters:
        'At 3 years, neuroimaging shows structural brain changes comparable to individuals who never used. Recovery is no longer an exception — it is your baseline.',
    themes: {
      'science': ThemedMilestone(
        name: 'Three Years',
        flavor:
            'Brain structure on scans now comparable to someone who never used.',
      ),
      'warrior': ThemedMilestone(
        name: 'Three-Tour Veteran',
        flavor:
            'Rare honour. Triple-deployment veteran. The army writes your name in stone.',
      ),
      'navy': ThemedMilestone(
        name: 'Legendary Voyage',
        flavor:
            'Three years; the stuff of sailors\' legends. Your voyage is now sung.',
      ),
      'clan': ThemedMilestone(
        name: 'Clan Founder',
        flavor:
            'Three years; your name is added to the founding scrolls of the clan.',
      ),
      'ancient': ThemedMilestone(
        name: 'Tribune',
        flavor: 'Three years; elected Tribune of the People by unanimous vote.',
      ),
      'samurai': ThemedMilestone(
        name: 'Daimyo',
        flavor:
            'Three years; land and domain granted. You rule with the sword and the brush.',
      ),
      'space': ThemedMilestone(
        name: 'Outer Planets',
        flavor:
            'Three years; crossing into the outer solar system. Jupiter ahead.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Prince of the Realm',
        flavor:
            'Three years; formally recognised as Prince. The crown studies you closely.',
      ),
      'monk': ThemedMilestone(
        name: 'Hermit Scholar',
        flavor:
            'Three years; a scholar of the sacred texts, sought for counsel.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Eternal Flame',
        flavor:
            'Three years; your flame can now never be extinguished by any storm.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 1460,
    dayLabel: '4 Years',
    whyItMatters:
        'Chronic stress response normalises at 4 years. Cortisol dysregulation — a core driver of relapse — is no longer a significant physiological risk factor.',
    themes: {
      'science': ThemedMilestone(
        name: 'Four Years',
        flavor:
            'Cortisol stress response normalised. A core relapse driver gone.',
      ),
      'warrior': ThemedMilestone(
        name: 'Special Forces Elite',
        flavor:
            'Four years marks formal entry into elite special operations. The few.',
      ),
      'navy': ThemedMilestone(
        name: 'Ocean Master',
        flavor:
            'Four years; every ocean navigated. The sea holds no secrets from you.',
      ),
      'clan': ThemedMilestone(
        name: "High King's Ally",
        flavor:
            'Four years; sworn ally of the High King. Your counsel shapes kingdoms.',
      ),
      'ancient': ThemedMilestone(
        name: 'Dictator of Virtue',
        flavor:
            'Four years; granted extraordinary powers for extraordinary deeds.',
      ),
      'samurai': ThemedMilestone(
        name: 'Legendary Ronin',
        flavor:
            'Four years; the legend of your discipline has spread to distant provinces.',
      ),
      'space': ThemedMilestone(
        name: 'Jupiter Fly-By',
        flavor:
            'Four years; gravitational slingshot around Jupiter. Speed and power now yours.',
      ),
      'kingdom': ThemedMilestone(
        name: "King's Hand",
        flavor:
            'Four years; ruling in the king\'s name. Every decision shapes the realm.',
      ),
      'monk': ThemedMilestone(
        name: 'Mystic',
        flavor:
            'Four years; experiencing the mystical union. Words cannot describe it.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Fire Keeper',
        flavor: 'Four years; you now carry fire for others lost in the dark.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 1825,
    dayLabel: '5 Years',
    whyItMatters:
        'At 5 years, population studies show your statistical risk of relapse is equal to that of someone who was never addicted. You are, by every measure, recovered.',
    themes: {
      'science': ThemedMilestone(
        name: 'Five Years',
        flavor:
            'Relapse risk statistically identical to a non-addicted person. Recovered.',
      ),
      'warrior': ThemedMilestone(
        name: 'Five-Star General',
        flavor:
            'Five years earns the highest battlefield honour. You command the army.',
      ),
      'navy': ThemedMilestone(
        name: 'Fleet Commander',
        flavor:
            'Five years; given command of the entire fleet. The ocean is yours.',
      ),
      'clan': ThemedMilestone(
        name: 'Legend of the Glen',
        flavor:
            'Five years; songs are sung of your deeds in every highland hall.',
      ),
      'ancient': ThemedMilestone(
        name: 'Pontifex Maximus',
        flavor:
            'Five years; made high priest, keeper of the most sacred rites of Rome.',
      ),
      'samurai': ThemedMilestone(
        name: 'Shogun',
        flavor:
            'Five years; appointed supreme military commander. All warriors bow.',
      ),
      'space': ThemedMilestone(
        name: 'Edge of System',
        flavor:
            'Five years; approaching the heliopause — the edge of our solar system.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Sovereign',
        flavor: 'Five years; crowned ruler of the realm. The kingdom is yours.',
      ),
      'monk': ThemedMilestone(
        name: 'Saint in Life',
        flavor:
            'Five years; revered as a living saint. Others pilgrimage to find you.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Constellation',
        flavor: 'Five years; your fire is now a star visible in the sky.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 2555,
    dayLabel: '7 Years',
    whyItMatters:
        'Every cell in the human body is replaced within 7 years. You are, at a cellular level, a completely different person from the one who last used.',
    themes: {
      'science': ThemedMilestone(
        name: 'Seven Years',
        flavor:
            'Every cell replaced. You are physically a different person than who started.',
      ),
      'warrior': ThemedMilestone(
        name: 'Legion of Valor',
        flavor:
            'Seven years earns the highest military distinction of the entire Legion.',
      ),
      'navy': ThemedMilestone(
        name: 'Seven Seas',
        flavor:
            'Seven years; all seven seas crossed and charted. Nothing left to fear.',
      ),
      'clan': ThemedMilestone(
        name: 'Ancestral Spirit',
        flavor:
            'Seven years; you have become the clan\'s living ancestor, respected by all.',
      ),
      'ancient': ThemedMilestone(
        name: 'Demigod',
        flavor:
            'Seven years; half-divine. The gods themselves have taken notice of you.',
      ),
      'samurai': ThemedMilestone(
        name: 'Seven Swords',
        flavor:
            'Seven years; said to have mastered all seven great sword traditions.',
      ),
      'space': ThemedMilestone(
        name: 'Interstellar',
        flavor:
            'Seven years; crossed the boundary of our solar system. Among the stars.',
      ),
      'kingdom': ThemedMilestone(
        name: 'High King',
        flavor:
            'Seven years; crowned High King of all the kingdoms. The age is yours.',
      ),
      'monk': ThemedMilestone(
        name: 'Enlightened',
        flavor:
            'Seven years; full enlightenment attained. The veil has dissolved.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Solar',
        flavor:
            'Seven years; you have become a star. Warmth and light for all.',
      ),
    },
  ),
  SobrietyMilestoneEntry(
    days: 3650,
    dayLabel: '10 Years',
    whyItMatters:
        'A decade clean. Complete physiological and psychological transformation. You are living proof that the brain can heal — an irreversible achievement.',
    themes: {
      'science': ThemedMilestone(
        name: 'A Decade',
        flavor:
            'Complete transformation. An irreversible, permanent achievement.',
      ),
      'warrior': ThemedMilestone(
        name: 'Hall of Heroes',
        flavor:
            'A decade of service; inducted into the Hall of Heroes for eternity.',
      ),
      'navy': ThemedMilestone(
        name: 'Maritime Legend',
        flavor:
            'A decade at sea; your name is carved into harbour stone forever.',
      ),
      'clan': ThemedMilestone(
        name: 'Eternal Chieftain',
        flavor:
            'A decade; your lineage rules the clan for generations to come.',
      ),
      'ancient': ThemedMilestone(
        name: 'Olympian',
        flavor:
            'A decade; ascended to sit among the gods of Olympus. Immortal.',
      ),
      'samurai': ThemedMilestone(
        name: 'Kensei',
        flavor:
            'A decade; Sword Saint. A living legend of total martial perfection.',
      ),
      'space': ThemedMilestone(
        name: 'Deep Space Pioneer',
        flavor:
            'A decade; among the stars, forever beyond the bounds of Earth.',
      ),
      'kingdom': ThemedMilestone(
        name: 'Immortal Legend',
        flavor:
            'A decade; your name is carved in the stones of eternity itself.',
      ),
      'monk': ThemedMilestone(
        name: 'Bodhisattva',
        flavor:
            'A decade; one who delays nirvana to return and help all others awaken.',
      ),
      'phoenix': ThemedMilestone(
        name: 'Cosmic Fire',
        flavor: 'A decade; you are the fire at the centre of existence itself.',
      ),
    },
  ),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns the name for a given milestone and theme.
String getMilestoneName(SobrietyMilestoneEntry entry, String themeId) {
  return entry.themes[themeId]?.name ?? entry.themes['science']!.name;
}

/// Returns the theme-flavoured "why it matters" for a given milestone and theme.
String getMilestoneFlavor(SobrietyMilestoneEntry entry, String themeId) {
  return entry.themes[themeId]?.flavor ?? entry.themes['science']!.flavor;
}

/// Returns the current and next milestone entries for the given duration.
({
  SobrietyMilestoneEntry? current,
  SobrietyMilestoneEntry? next,
  double progress,
  String remainingLabel,
})
getMilestoneProgress(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours;

  SobrietyMilestoneEntry? current;
  SobrietyMilestoneEntry? next;

  for (final m in kSobrietyMilestones) {
    if (days >= m.days) {
      current = m;
    } else {
      next = m;
      break;
    }
  }

  if (current == null) {
    // Before first milestone
    final targetHours = kSobrietyMilestones.first.days * 24;
    final progress = (hours / targetHours).clamp(0.0, 1.0);
    final hoursLeft = targetHours - hours;
    return (
      current: null,
      next: kSobrietyMilestones.first,
      progress: progress,
      remainingLabel: hoursLeft > 0
          ? '${hoursLeft}h to ${kSobrietyMilestones.first.dayLabel}'
          : '',
    );
  }

  if (next == null) {
    // Past last milestone
    return (
      current: current,
      next: null,
      progress: 1.0,
      remainingLabel: 'All milestones achieved',
    );
  }

  final currentHours = current.days * 24;
  final nextHours = next.days * 24;
  final progress = ((hours - currentHours) / (nextHours - currentHours)).clamp(
    0.0,
    1.0,
  );
  final hoursLeft = nextHours - hours;
  final remainingLabel = hoursLeft >= 24
      ? '${(hoursLeft / 24).ceil()}d to ${next.dayLabel}'
      : '${hoursLeft}h to ${next.dayLabel}';

  return (
    current: current,
    next: next,
    progress: progress,
    remainingLabel: remainingLabel,
  );
}
