// Sobriety Milestone Data
//
// 21 milestones from 1 to 3650 days (10 years), all rooted in addiction
// neuroscience, PAWS research, fMRI studies, and behavioural psychology.
//
// 34 themed name sets give users psychological resonance with their
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
  final String flavor;
}

class SobrietyMilestoneEntry {
  const SobrietyMilestoneEntry({
    required this.days,
    required this.dayLabel,
    required this.whyItMatters,
  });

  final int days;
  final String dayLabel;
  final String whyItMatters;
}

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

// Theme list metadata
const List<MilestoneTheme> kMilestoneThemes = [
  MilestoneTheme(
    id: "science",
    name: "Science",
    emoji: "🔬",
    description: "Clinical neuroscience terms. Cold, precise, honest.",
  ),
  MilestoneTheme(
    id: "warrior",
    name: "Warrior",
    emoji: "⚔️",
    description: "Army elite. Every clean day is a battle fought and won.",
  ),
  MilestoneTheme(
    id: "navy",
    name: "Navy",
    emoji: "⚓",
    description: "Seafaring odyssey. Chart new waters and never look back.",
  ),
  MilestoneTheme(
    id: "clan",
    name: "Clan",
    emoji: "🏔️",
    description: "Celtic highland clan. Earn your place, carry the banner.",
  ),
  MilestoneTheme(
    id: "ancient",
    name: "Ancient",
    emoji: "🏛️",
    description: "Greek and Roman glory. Rise from mortal to Olympian.",
  ),
  MilestoneTheme(
    id: "samurai",
    name: "Samurai",
    emoji: "🗡️",
    description: "Bushido code. Master of the self.",
  ),
  MilestoneTheme(
    id: "space",
    name: "Space",
    emoji: "🚀",
    description: "Cosmic exploration. Every clean day is light-years gained.",
  ),
  MilestoneTheme(
    id: "kingdom",
    name: "Kingdom",
    emoji: "👑",
    description: "Medieval royalty. Rise from serf to sovereign.",
  ),
  MilestoneTheme(
    id: "monk",
    name: "Monk",
    emoji: "🙏",
    description: "Monastic journey. Silence, stillness, and vows.",
  ),
  MilestoneTheme(
    id: "phoenix",
    name: "Phoenix",
    emoji: "🔥",
    description: "Rebirth through fire. The old is ash; you are the flame.",
  ),
  MilestoneTheme(
    id: "animals",
    name: "Animal Kingdom",
    emoji: "🦁",
    description: "Survival of the fittest. Tardigrade to mythical Dragon.",
  ),
  MilestoneTheme(
    id: "pokemon",
    name: "Pokemon",
    emoji: "⚡",
    description: "Magikarp to the creator god Arceus.",
  ),
  MilestoneTheme(
    id: "jjk",
    name: "Jujutsu Kaisen",
    emoji: "🧿",
    description: "Cursed spirit to Satoru Gojo.",
  ),
  MilestoneTheme(
    id: "onepiece",
    name: "One Piece",
    emoji: "☠️",
    description: "East Blue Coby to the Pirate King Gol D. Roger.",
  ),
  MilestoneTheme(
    id: "naruto",
    name: "Naruto",
    emoji: "🍥",
    description: "Konohamaru to the Sage of Six Paths.",
  ),
  MilestoneTheme(
    id: "ben10",
    name: "Ben 10",
    emoji: "⌚",
    description: "Grey Matter to Alien X.",
  ),
  MilestoneTheme(
    id: "aot",
    name: "Attack on Titan",
    emoji: "🧱",
    description: "Pure Titan to the Founder Ymir Fritz.",
  ),
  MilestoneTheme(
    id: "bleach",
    name: "Bleach",
    emoji: "🌙",
    description: "Teddy bear Kon to Yhwach the Almighty.",
  ),
  MilestoneTheme(
    id: "mha",
    name: "My Hero Academia",
    emoji: "💥",
    description: "Mineta to All Might Prime.",
  ),
  MilestoneTheme(
    id: "vinland",
    name: "Vinland Saga",
    emoji: "🪓",
    description: "Priest Willibald to Thors the Troll of Jom.",
  ),
  MilestoneTheme(
    id: "demonslayer",
    name: "Demon Slayer",
    emoji: "🏮",
    description: "Murata to Yoriichi Tsugikuni.",
  ),
  MilestoneTheme(
    id: "fma",
    name: "Fullmetal Alchemist",
    emoji: "🦾",
    description: "Yoki to the ultimate Truth.",
  ),
  MilestoneTheme(
    id: "dbz",
    name: "Dragon Ball",
    emoji: "☄️",
    description: "Yamcha to the Omni-King Zeno.",
  ),
  MilestoneTheme(
    id: "codegeass",
    name: "Code Geass",
    emoji: "👁️",
    description: "Shirley to Emperor Lelouch vi Britannia.",
  ),
  MilestoneTheme(
    id: "deathnote",
    name: "Death Note",
    emoji: "📓",
    description: "Matsuda to the Shinigami King.",
  ),
  MilestoneTheme(
    id: "gintama",
    name: "Gintama",
    emoji: "🕶️",
    description: "Shinpachi to Utsuro.",
  ),
  MilestoneTheme(
    id: "hxh",
    name: "Hunter x Hunter",
    emoji: "🎣",
    description: "Tonpa to Adult Gon.",
  ),
  MilestoneTheme(
    id: "sololeveling",
    name: "Solo Leveling",
    emoji: "🌌",
    description: "E-Rank Sung Jinwoo to Shadow Monarch.",
  ),
  MilestoneTheme(
    id: "rpg",
    name: "RPG / Minecraft",
    emoji: "⛏️",
    description: "Wooden Shovel to Creative Mode God.",
  ),
  MilestoneTheme(
    id: "tech",
    name: "Tech Career",
    emoji: "💻",
    description: "HTML editor to Turing Award Winner.",
  ),
  MilestoneTheme(
    id: "chess",
    name: "Chess Mastery",
    emoji: "♟️",
    description: "Scholar's Mate victim to Magnus Carlsen.",
  ),
  MilestoneTheme(
    id: "starwars",
    name: "Star Wars",
    emoji: "🌌",
    description: "Moisture farmer to the Chosen One.",
  ),
  MilestoneTheme(
    id: "potter",
    name: "Harry Potter",
    emoji: "⚡",
    description: "Muggle to Merlin.",
  ),
  MilestoneTheme(
    id: "marvel",
    name: "Marvel Universe",
    emoji: "🛡️",
    description: "Civilian to The One Above All.",
  ),
];

// Universal 21 Milestones
const List<SobrietyMilestoneEntry> kSobrietyMilestones = [
  SobrietyMilestoneEntry(
    days: 1,
    dayLabel: "1 Day",
    whyItMatters:
        "Acute withdrawal begins. The body starts clearing toxins within the first 24 hours — the hardest window.",
  ),
  SobrietyMilestoneEntry(
    days: 3,
    dayLabel: "3 Days",
    whyItMatters:
        "Physical withdrawal peaks at 72 hours for most substances. Cravings are at their most intense — surviving this is a major neurological victory.",
  ),
  SobrietyMilestoneEntry(
    days: 7,
    dayLabel: "1 Week",
    whyItMatters:
        "The brain resumes baseline dopamine production after 7 days. The first reward-cycle completes, and mood begins to stabilise.",
  ),
  SobrietyMilestoneEntry(
    days: 14,
    dayLabel: "2 Weeks",
    whyItMatters:
        "REM sleep architecture normalises after 14 days — deep sleep returns. Mood swings reduce significantly as serotonin stabilises.",
  ),
  SobrietyMilestoneEntry(
    days: 21,
    dayLabel: "21 Days",
    whyItMatters:
        "Neural plasticity research identifies 21 days as the threshold where cortical grooves begin rewiring. Old pathways weaken; new ones are forming.",
  ),
  SobrietyMilestoneEntry(
    days: 30,
    dayLabel: "30 Days",
    whyItMatters:
        "The liver completes a full detox cycle. The prefrontal cortex — the seat of willpower — begins measurable structural recovery.",
  ),
  SobrietyMilestoneEntry(
    days: 45,
    dayLabel: "45 Days",
    whyItMatters:
        "Post-Acute Withdrawal Syndrome (PAWS) — the wave of cravings, anxiety and insomnia after physical detox — begins fading noticeably at 45 days.",
  ),
  SobrietyMilestoneEntry(
    days: 60,
    dayLabel: "2 Months",
    whyItMatters:
        "Neuroimaging (fMRI) studies show measurable grey-matter regrowth in the prefrontal cortex at the 60-day mark — physical brain healing you can scan.",
  ),
  SobrietyMilestoneEntry(
    days: 90,
    dayLabel: "90 Days",
    whyItMatters:
        "The clinical gold standard. Most residential treatment programmes are 90 days for a reason: dopamine pathways show visible healing on fMRI at this point.",
  ),
  SobrietyMilestoneEntry(
    days: 100,
    dayLabel: "100 Days",
    whyItMatters:
        "A psychologically powerful round number. Three complete monthly hormonal cycles have passed, reinforcing the psychological identity of 'someone who doesn't use'.",
  ),
  SobrietyMilestoneEntry(
    days: 180,
    dayLabel: "6 Months",
    whyItMatters:
        "Emotional regulation returns to pre-addiction baseline at 6 months. Anger, anxiety, and impulsivity are measurably reduced. You feel like yourself again.",
  ),
  SobrietyMilestoneEntry(
    days: 270,
    dayLabel: "9 Months",
    whyItMatters:
        "9 months mirrors the gestational period — a full neuroplasticity cycle has completed. Your brain has, in a very real sense, rebuilt itself from scratch.",
  ),
  SobrietyMilestoneEntry(
    days: 365,
    dayLabel: "1 Year",
    whyItMatters:
        "A full year means you have experienced every seasonal trigger — holidays, anniversaries, seasons — at least once and stayed clean. PAWS is typically gone.",
  ),
  SobrietyMilestoneEntry(
    days: 500,
    dayLabel: "500 Days",
    whyItMatters:
        "Relapse rate drops sharply between year one and year two. At 500 days, research shows most recoveries have crossed into stable long-term remission territory.",
  ),
  SobrietyMilestoneEntry(
    days: 548,
    dayLabel: "18 Months",
    whyItMatters:
        "Research shows PAWS is completely resolved in 95 % of individuals at 18 months. Your baseline brain chemistry is now functionally normal.",
  ),
  SobrietyMilestoneEntry(
    days: 730,
    dayLabel: "2 Years",
    whyItMatters:
        "Long-term recovery officially begins at 2 years. Dopamine pathways are fully rebuilt. The Journal of Substance Abuse Treatment classifies 2+ years as the stable recovery phase.",
  ),
  SobrietyMilestoneEntry(
    days: 1095,
    dayLabel: "3 Years",
    whyItMatters:
        "At 3 years, neuroimaging shows structural brain changes comparable to individuals who never used. Recovery is no longer an exception — it is your baseline.",
  ),
  SobrietyMilestoneEntry(
    days: 1460,
    dayLabel: "4 Years",
    whyItMatters:
        "Chronic stress response normalises at 4 years. Cortisol dysregulation — a core driver of relapse — is no longer a significant physiological risk factor.",
  ),
  SobrietyMilestoneEntry(
    days: 1825,
    dayLabel: "5 Years",
    whyItMatters:
        "At 5 years, population studies show your statistical risk of relapse is equal to that of someone who was never addicted. You are, by every measure, recovered.",
  ),
  SobrietyMilestoneEntry(
    days: 2555,
    dayLabel: "7 Years",
    whyItMatters:
        "Every cell in the human body is replaced within 7 years. You are, at a cellular level, a completely different person from the one who last used.",
  ),
  SobrietyMilestoneEntry(
    days: 3650,
    dayLabel: "10 Years",
    whyItMatters:
        "A decade clean. Complete physiological and psychological transformation. You are living proof that the brain can heal — an irreversible achievement.",
  ),
];

// Map of Theme ID to 21 Milestone Names & Flavors
const Map<String, List<ThemedMilestone>> kThemeMilestones = {
  "science": [
    ThemedMilestone(
      name: "First Sunrise",
      flavor: "Acute toxin clearance begins. Every hour now counts.",
    ),
    ThemedMilestone(
      name: "Peak Storm",
      flavor: "Withdrawal at its worst. Your brain chemistry is fighting back.",
    ),
    ThemedMilestone(
      name: "First Week",
      flavor: "Dopamine baseline restored. The reward system is rebooting.",
    ),
    ThemedMilestone(
      name: "Neural Thaw",
      flavor: "REM sleep returns. Your brain is thawing from the freeze.",
    ),
    ThemedMilestone(
      name: "Habit Horizon",
      flavor:
          "Cortical rewiring threshold crossed. Old pathways are losing power.",
    ),
    ThemedMilestone(
      name: "One Month",
      flavor:
          "Liver detox complete. Prefrontal cortex structural recovery begins.",
    ),
    ThemedMilestone(
      name: "Turning Point",
      flavor: "PAWS symptoms begin fading. The fog is lifting.",
    ),
    ThemedMilestone(
      name: "Two Months",
      flavor: "fMRI-detectable grey-matter regrowth. Your brain is rebuilding.",
    ),
    ThemedMilestone(
      name: "The 90",
      flavor:
          "Clinical gold standard. Dopamine pathways visibly healed on fMRI.",
    ),
    ThemedMilestone(
      name: "Century",
      flavor:
          "Three full monthly cycles. Your brain's identity is rewriting itself.",
    ),
    ThemedMilestone(
      name: "Half Year",
      flavor:
          "Emotional regulation back at baseline. You feel like yourself again.",
    ),
    ThemedMilestone(
      name: "Gestation",
      flavor: "A full neuroplasticity cycle. Your brain is effectively new.",
    ),
    ThemedMilestone(
      name: "Full Orbit",
      flavor:
          "Every seasonal trigger faced once. PAWS resolved for most at this point.",
    ),
    ThemedMilestone(
      name: "500 Days",
      flavor:
          "Relapse risk drops sharply. Stable long-term remission territory.",
    ),
    ThemedMilestone(
      name: "Year & Half",
      flavor:
          "PAWS resolved in 95 % of cases at this point. Brain chemistry normal.",
    ),
    ThemedMilestone(
      name: "Two Years",
      flavor:
          "Long-term recovery phase begins. Dopamine pathways fully rebuilt.",
    ),
    ThemedMilestone(
      name: "Three Years",
      flavor:
          "Brain structure on scans now comparable to someone who never used.",
    ),
    ThemedMilestone(
      name: "Four Years",
      flavor:
          "Cortisol stress response normalised. A core relapse driver gone.",
    ),
    ThemedMilestone(
      name: "Five Years",
      flavor:
          "Relapse risk statistically identical to a non-addicted person. Recovered.",
    ),
    ThemedMilestone(
      name: "Seven Years",
      flavor:
          "Every cell replaced. You are physically a different person than who started.",
    ),
    ThemedMilestone(
      name: "A Decade",
      flavor:
          "Complete transformation. An irreversible, permanent achievement.",
    ),
  ],
  "warrior": [
    ThemedMilestone(
      name: "First March",
      flavor: "Every long campaign starts with a single step. March.",
    ),
    ThemedMilestone(
      name: "Fire Baptism",
      flavor: "The fiercest storms forge the strongest soldiers.",
    ),
    ThemedMilestone(
      name: "Field Proven",
      flavor: "A week in the field proves your resolve to your platoon.",
    ),
    ThemedMilestone(
      name: "FOB Established",
      flavor: "Forward base secured. Supply lines are running. Dig in.",
    ),
    ThemedMilestone(
      name: "Combat Hardened",
      flavor: "Three weeks turns a raw recruit into a battle-hardened soldier.",
    ),
    ThemedMilestone(
      name: "Tour Launched",
      flavor: "First full month on active duty. The mission is under way.",
    ),
    ThemedMilestone(
      name: "Midpoint Patrol",
      flavor: "Past the halfway mark; enemy contact reducing. Hold formation.",
    ),
    ThemedMilestone(
      name: "Operation Secured",
      flavor:
          "The front line has been held for two full months. Well done, soldier.",
    ),
    ThemedMilestone(
      name: "Campaign Medal",
      flavor:
          "The 90-day campaign. Awarded only to those who survived the full engagement.",
    ),
    ThemedMilestone(
      name: "Centurion Mark",
      flavor:
          "100 days of unbroken service earns the centurion mark on your record.",
    ),
    ThemedMilestone(
      name: "Six-Month Citation",
      flavor: "Half-year citation for distinguished and unbroken service.",
    ),
    ThemedMilestone(
      name: "Nine-Month Commendation",
      flavor:
          "Strategic mastery demonstrated across nine gruelling months of deployment.",
    ),
    ThemedMilestone(
      name: "First Tour Complete",
      flavor: "Full year of deployment without once breaking ranks. Immovable.",
    ),
    ThemedMilestone(
      name: "Iron Cross",
      flavor:
          "Awarded to soldiers who held position across 500 gruelling missions.",
    ),
    ThemedMilestone(
      name: "Senior Commando",
      flavor: "18 months of elite special operations without a single failure.",
    ),
    ThemedMilestone(
      name: "Double Tour",
      flavor:
          "Two years of unwavering active service. Double tour. A rare honour.",
    ),
    ThemedMilestone(
      name: "Three-Tour Veteran",
      flavor:
          "Rare honour. Triple-deployment veteran. The army writes your name in stone.",
    ),
    ThemedMilestone(
      name: "Special Forces Elite",
      flavor:
          "Four years marks formal entry into elite special operations. The few.",
    ),
    ThemedMilestone(
      name: "Five-Star General",
      flavor:
          "Five years earns the highest battlefield honour. You command the army.",
    ),
    ThemedMilestone(
      name: "Legion of Valor",
      flavor:
          "Seven years earns the highest military distinction of the entire Legion.",
    ),
    ThemedMilestone(
      name: "Hall of Heroes",
      flavor:
          "A decade of service; inducted into the Hall of Heroes for eternity.",
    ),
  ],
  "navy": [
    ThemedMilestone(
      name: "Cast Off",
      flavor: "Lines released, tides turning — the voyage has begun.",
    ),
    ThemedMilestone(
      name: "Open Water",
      flavor: "Land is gone from view. Fully in open sea.",
    ),
    ThemedMilestone(
      name: "First Storm Past",
      flavor: "The first storm weathered. Sea legs found.",
    ),
    ThemedMilestone(
      name: "Midwatch",
      flavor:
          "The darkest watch before dawn — and you held it without flinching.",
    ),
    ThemedMilestone(
      name: "Steady Bearing",
      flavor: "Three weeks at sea; course locked, compass true, helm steady.",
    ),
    ThemedMilestone(
      name: "First Port",
      flavor: "One month at sea — the first harbour in sight. You made it.",
    ),
    ThemedMilestone(
      name: "Deep Water",
      flavor: "Past the continental shelf. No shallow water to retreat to.",
    ),
    ThemedMilestone(
      name: "Longitude Marked",
      flavor:
          "Two months; a new longitude charted. You are further than you've ever been.",
    ),
    ThemedMilestone(
      name: "Far Shore",
      flavor: "The 90-day crossing. Another coast reached. Chart it.",
    ),
    ThemedMilestone(
      name: "Century League",
      flavor: "100 nautical leagues logged into the ship's master ledger.",
    ),
    ThemedMilestone(
      name: "Equator Crossed",
      flavor:
          "Halfway around the world. Neptune is honoured. The crew celebrates.",
    ),
    ThemedMilestone(
      name: "Three Quarters Round",
      flavor:
          "Nine months; three-quarters of a full circumnavigation of the globe.",
    ),
    ThemedMilestone(
      name: "Circumnavigation",
      flavor:
          "A year at sea; the globe has been rounded once. Your name is in the log.",
    ),
    ThemedMilestone(
      name: "Five Hundred Fathoms",
      flavor: "Half a thousand days plumbing the deepest waters.",
    ),
    ThemedMilestone(
      name: "Admiral's Citation",
      flavor:
          "Eighteen months earns the Admiral's personal and public commendation.",
    ),
    ThemedMilestone(
      name: "Two-Year Voyage",
      flavor:
          "Two years; the great explorers' standard. You are among the legendary.",
    ),
    ThemedMilestone(
      name: "Legendary Voyage",
      flavor:
          "Three years; the stuff of sailors' legends. Your voyage is now sung.",
    ),
    ThemedMilestone(
      name: "Ocean Master",
      flavor:
          "Four years; every ocean navigated. The sea holds no secrets from you.",
    ),
    ThemedMilestone(
      name: "Fleet Commander",
      flavor:
          "Five years; given command of the entire fleet. The ocean is yours.",
    ),
    ThemedMilestone(
      name: "Seven Seas",
      flavor:
          "Seven years; all seven seas crossed and charted. Nothing left to fear.",
    ),
    ThemedMilestone(
      name: "Maritime Legend",
      flavor:
          "A decade at sea; your name is carved into harbour stone forever.",
    ),
  ],
  "clan": [
    ThemedMilestone(
      name: "Initiate's Oath",
      flavor: "The oath is sworn before the fire. No turning back.",
    ),
    ThemedMilestone(
      name: "Trial by Fire",
      flavor: "Every clan member faces three days of initiation fire.",
    ),
    ThemedMilestone(
      name: "Blood Week",
      flavor: "A week of proving blood ties. The clan watches.",
    ),
    ThemedMilestone(
      name: "Kinship Bond",
      flavor:
          "Two weeks; kinship bonds are forged in shared struggle and fire.",
    ),
    ThemedMilestone(
      name: "Shield Bearer",
      flavor:
          "Three weeks; earned the right to carry the clan's sacred shield.",
    ),
    ThemedMilestone(
      name: "Clan Member",
      flavor: "Full membership earned after the first full moon cycle.",
    ),
    ThemedMilestone(
      name: "Trusted Kin",
      flavor: "45 days; the clan begins to trust your counsel in war councils.",
    ),
    ThemedMilestone(
      name: "Elder's Favour",
      flavor:
          "Two months; a clan elder vouches for your strength of character.",
    ),
    ThemedMilestone(
      name: "War Council",
      flavor: "90 days; invited to sit and speak at the war council fire.",
    ),
    ThemedMilestone(
      name: "Clan Champion",
      flavor: "100 days; named champion of the annual highland gathering.",
    ),
    ThemedMilestone(
      name: "Clan Elder",
      flavor: "Six months earns the grey sash of the clan elder. Hard-won.",
    ),
    ThemedMilestone(
      name: "Keeper of Lore",
      flavor:
          "Nine months; entrusted with the clan's oral history. The stories live in you.",
    ),
    ThemedMilestone(
      name: "High Council",
      flavor: "A full year; your seat on the high council is formally secured.",
    ),
    ThemedMilestone(
      name: "Warchief's Shadow",
      flavor:
          "500 days; you walk in the warchief's shadow as most trusted advisor.",
    ),
    ThemedMilestone(
      name: "Guardian of the Hearth",
      flavor: "18 months; guardian of the clan's sacred and eternal flame.",
    ),
    ThemedMilestone(
      name: "Warchief",
      flavor:
          "Two years; elected to lead the clan in both battle and peacetime.",
    ),
    ThemedMilestone(
      name: "Clan Founder",
      flavor:
          "Three years; your name is added to the founding scrolls of the clan.",
    ),
    ThemedMilestone(
      name: "High King's Ally",
      flavor:
          "Four years; sworn ally of the High King. Your counsel shapes kingdoms.",
    ),
    ThemedMilestone(
      name: "Legend of the Glen",
      flavor:
          "Five years; songs are sung of your deeds in every highland hall.",
    ),
    ThemedMilestone(
      name: "Ancestral Spirit",
      flavor:
          "Seven years; you have become the clan's living ancestor, respected by all.",
    ),
    ThemedMilestone(
      name: "Eternal Chieftain",
      flavor: "A decade; your lineage rules the clan for generations to come.",
    ),
  ],
  "ancient": [
    ThemedMilestone(
      name: "First Rite",
      flavor: "The sacred rites of purification begin at dawn.",
    ),
    ThemedMilestone(
      name: "Trial of Olympus",
      flavor: "Three ordeals faced by every hero worth legend.",
    ),
    ThemedMilestone(
      name: "Agoge Begins",
      flavor:
          "Seven days; enrolled in the training programme of Spartan warriors.",
    ),
    ThemedMilestone(
      name: "The Forge",
      flavor: "Two weeks on the forge. The hero is taking shape.",
    ),
    ThemedMilestone(
      name: "Oracle's Word",
      flavor: "Twenty-one days; the Oracle speaks of your destiny.",
    ),
    ThemedMilestone(
      name: "First Games",
      flavor:
          "One month; entered in the first of the Olympian competitive games.",
    ),
    ThemedMilestone(
      name: "Laurel of Apollo",
      flavor: "45 days; Apollo grants the first laurel wreath for endurance.",
    ),
    ThemedMilestone(
      name: "Consul's Recognition",
      flavor:
          "Two months; the Roman Consul formally acknowledges your discipline.",
    ),
    ThemedMilestone(
      name: "Centurion",
      flavor:
          "The 90-day threshold that separates soldiers from centurions. Rise.",
    ),
    ThemedMilestone(
      name: "Senate Record",
      flavor: "100 days inscribed in the Roman Senate records of honour.",
    ),
    ThemedMilestone(
      name: "Praetor",
      flavor:
          "Six months; promoted to Praetor, administrator of justice in the city.",
    ),
    ThemedMilestone(
      name: "Nine Muses' Gift",
      flavor:
          "Nine months; all nine Muses have bestowed their wisdom upon you.",
    ),
    ThemedMilestone(
      name: "Year of the Gods",
      flavor:
          "A full year blessed by all twelve Olympian gods. Favour is with you.",
    ),
    ThemedMilestone(
      name: "500 Days of Sparta",
      flavor: "500 days standing unbroken at the hot gates of discipline.",
    ),
    ThemedMilestone(
      name: "Hero of Athens",
      flavor:
          "18 months; a bronze statue is erected in your honour in the Athenian agora.",
    ),
    ThemedMilestone(
      name: "Proconsul",
      flavor:
          "Two years; governing with full proconsular authority over a province.",
    ),
    ThemedMilestone(
      name: "Tribune",
      flavor: "Three years; elected Tribune of the People by unanimous vote.",
    ),
    ThemedMilestone(
      name: "Dictator of Virtue",
      flavor:
          "Four years; granted extraordinary powers for extraordinary deeds.",
    ),
    ThemedMilestone(
      name: "Pontifex Maximus",
      flavor:
          "Five years; made high priest, keeper of the most sacred rites of Rome.",
    ),
    ThemedMilestone(
      name: "Demigod",
      flavor:
          "Seven years; half-divine. The gods themselves have taken notice of you.",
    ),
    ThemedMilestone(
      name: "Olympian",
      flavor: "A decade; ascended to sit among the gods of Olympus. Immortal.",
    ),
  ],
  "samurai": [
    ThemedMilestone(
      name: "Seiza",
      flavor: "The warrior settles into stillness. The trial begins.",
    ),
    ThemedMilestone(
      name: "First Blood",
      flavor:
          "The blade has been tested against the fiercest enemy — the self.",
    ),
    ThemedMilestone(
      name: "Dojo Accepted",
      flavor: "Seven days; formally accepted as a student of the dojo.",
    ),
    ThemedMilestone(
      name: "Two-Week Strike",
      flavor: "Form begins taking shape. Muscle memory is awakening.",
    ),
    ThemedMilestone(
      name: "Third Kata",
      flavor: "Three weeks; mastery of the third form of the kata confirmed.",
    ),
    ThemedMilestone(
      name: "Moon Training",
      flavor:
          "One full moon of daily practice without a single missed session.",
    ),
    ThemedMilestone(
      name: "Steel Folded",
      flavor: "45 days; the blade has been folded forty times in the forge.",
    ),
    ThemedMilestone(
      name: "Two-Month Zazen",
      flavor:
          "Two months of daily zazen — seated meditation — without exception.",
    ),
    ThemedMilestone(
      name: "Ronin No More",
      flavor:
          "90 days; the wandering warrior has found their path and their dojo.",
    ),
    ThemedMilestone(
      name: "Ink on Scroll",
      flavor: "100 days; the sensei records your name on the honour scroll.",
    ),
    ThemedMilestone(
      name: "Samurai",
      flavor:
          "Six months earns the title Samurai. You have proven the bushido code lives in you.",
    ),
    ThemedMilestone(
      name: "Senior Samurai",
      flavor:
          "Nine months; trusted with guarding the domain lord's inner chambers.",
    ),
    ThemedMilestone(
      name: "Year of the Blade",
      flavor: "A full year; the sword is now an extension of the soul itself.",
    ),
    ThemedMilestone(
      name: "Five-Ring Master",
      flavor:
          "500 days reflecting on the Book of Five Rings. Total master of strategy.",
    ),
    ThemedMilestone(
      name: "Hatamoto",
      flavor:
          "18 months; elevated to direct retainer of the Shogun's inner court.",
    ),
    ThemedMilestone(
      name: "Senior Hatamoto",
      flavor:
          "Two years; senior advisor sitting at the Shogun's own court table.",
    ),
    ThemedMilestone(
      name: "Daimyo",
      flavor:
          "Three years; land and domain granted. You rule with the sword and the brush.",
    ),
    ThemedMilestone(
      name: "Legendary Ronin",
      flavor:
          "Four years; the legend of your discipline has spread to distant provinces.",
    ),
    ThemedMilestone(
      name: "Shogun",
      flavor:
          "Five years; appointed supreme military commander. All warriors bow.",
    ),
    ThemedMilestone(
      name: "Seven Swords",
      flavor:
          "Seven years; said to have mastered all seven great sword traditions.",
    ),
    ThemedMilestone(
      name: "Kensei",
      flavor:
          "A decade; Sword Saint. A living legend of total martial perfection.",
    ),
  ],
  "space": [
    ThemedMilestone(
      name: "Launch",
      flavor: "Engines ignite. Mission clock is running.",
    ),
    ThemedMilestone(
      name: "Escape Velocity",
      flavor: "Free from the gravity well. No orbit, only forward.",
    ),
    ThemedMilestone(
      name: "First Orbit",
      flavor: "Seven days in space; one full orbit of the Earth complete.",
    ),
    ThemedMilestone(
      name: "Adapted to Zero-G",
      flavor: "Two weeks; the body has fully adjusted to the void.",
    ),
    ThemedMilestone(
      name: "Module Docked",
      flavor: "21 days; docking with the station — mission critical achieved.",
    ),
    ThemedMilestone(
      name: "Lunar Month",
      flavor: "One full lunar cycle observed from the silence of orbit.",
    ),
    ThemedMilestone(
      name: "Halfway to Moon",
      flavor: "45 days; the midpoint of a lunar transfer trajectory.",
    ),
    ThemedMilestone(
      name: "Deep Space",
      flavor: "Two months; outside cislunar space. No turning back now.",
    ),
    ThemedMilestone(
      name: "Quarter Year",
      flavor: "The mission has reached its first major deep-space waypoint.",
    ),
    ThemedMilestone(
      name: "Century Mark",
      flavor:
          "Mission control marks 100 mission days with a ceremony on the ground.",
    ),
    ThemedMilestone(
      name: "ISS Milestone",
      flavor:
          "Six months; the ISS benchmark. Crew health fully adapted to the void.",
    ),
    ThemedMilestone(
      name: "Mars Transfer Window",
      flavor: "Nine months; approaching the Mars transfer orbital window.",
    ),
    ThemedMilestone(
      name: "Full Orbit",
      flavor:
          "One complete revolution around the sun. Mission: year one complete.",
    ),
    ThemedMilestone(
      name: "Asteroid Belt",
      flavor: "Crossing the asteroid belt into deep space proper.",
    ),
    ThemedMilestone(
      name: "Martian Orbit",
      flavor: "18 months; arriving at Mars. The red planet hangs before you.",
    ),
    ThemedMilestone(
      name: "Mars Surface",
      flavor: "Two years; first boot prints on Martian soil. History written.",
    ),
    ThemedMilestone(
      name: "Outer Planets",
      flavor:
          "Three years; crossing into the outer solar system. Jupiter ahead.",
    ),
    ThemedMilestone(
      name: "Jupiter Fly-By",
      flavor:
          "Four years; gravitational slingshot around Jupiter. Speed and power now yours.",
    ),
    ThemedMilestone(
      name: "Edge of System",
      flavor:
          "Five years; approaching the heliopause — the edge of our solar system.",
    ),
    ThemedMilestone(
      name: "Interstellar",
      flavor:
          "Seven years; crossed the boundary of our solar system. Among the stars.",
    ),
    ThemedMilestone(
      name: "Deep Space Pioneer",
      flavor: "A decade; among the stars, forever beyond the bounds of Earth.",
    ),
  ],
  "kingdom": [
    ThemedMilestone(
      name: "Serf to Freeman",
      flavor: "The chains are broken. You walk free for the first time.",
    ),
    ThemedMilestone(
      name: "Dungeon Survivor",
      flavor: "Three days endured in the mind's darkest dungeon.",
    ),
    ThemedMilestone(
      name: "Village Guard",
      flavor:
          "Seven days of service; trusted to stand watch on the village gate.",
    ),
    ThemedMilestone(
      name: "Town Militia",
      flavor: "Two weeks; promoted to captain of the town militia.",
    ),
    ThemedMilestone(
      name: "King's Messenger",
      flavor: "21 days; trusted to carry the king's messages across the realm.",
    ),
    ThemedMilestone(
      name: "Knight's Squire",
      flavor:
          "One month; formally accepted as squire to a Knight of the Realm.",
    ),
    ThemedMilestone(
      name: "Battlefield Tested",
      flavor: "45 days; you have survived the first great battle of the self.",
    ),
    ThemedMilestone(
      name: "Knight-in-Training",
      flavor: "Two months; formal knighthood training has officially begun.",
    ),
    ThemedMilestone(
      name: "Knighted",
      flavor: "The sword touches each shoulder. Rise, Knight of the Realm.",
    ),
    ThemedMilestone(
      name: "Tournament Champion",
      flavor: "100 days; named champion of the great annual tournament.",
    ),
    ThemedMilestone(
      name: "Baron",
      flavor:
          "Six months; a barony of land granted by the crown. Govern it well.",
    ),
    ThemedMilestone(
      name: "Lord Commander",
      flavor:
          "Nine months; commanding the entire castle garrison with full authority.",
    ),
    ThemedMilestone(
      name: "Count",
      flavor:
          "A full year; elevated to the rank of Count. A territory is yours.",
    ),
    ThemedMilestone(
      name: "Marquis",
      flavor: "500 days; governing the borderlands with iron discipline.",
    ),
    ThemedMilestone(
      name: "Duke",
      flavor:
          "18 months; elevated to Duke — second only to the royal family in power.",
    ),
    ThemedMilestone(
      name: "Grand Duke",
      flavor: "Two years; given a grand duchy. Your legacy is being built.",
    ),
    ThemedMilestone(
      name: "Prince of the Realm",
      flavor:
          "Three years; formally recognised as Prince. The crown studies you closely.",
    ),
    ThemedMilestone(
      name: "King's Hand",
      flavor:
          "Four years; ruling in the king's name. Every decision shapes the realm.",
    ),
    ThemedMilestone(
      name: "Sovereign",
      flavor: "Five years; crowned ruler of the realm. The kingdom is yours.",
    ),
    ThemedMilestone(
      name: "High King",
      flavor:
          "Seven years; crowned High King of all the kingdoms. The age is yours.",
    ),
    ThemedMilestone(
      name: "Immortal Legend",
      flavor: "A decade; your name is carved in the stones of eternity itself.",
    ),
  ],
  "monk": [
    ThemedMilestone(
      name: "First Vow",
      flavor: "The vow of abstinence is taken at dawn. The bell rings.",
    ),
    ThemedMilestone(
      name: "Silent Vigil",
      flavor: "Three days of silence. The mind begins, slowly, to quiet.",
    ),
    ThemedMilestone(
      name: "Novitiate",
      flavor: "Seven days; officially enrolled as a novice of the monastery.",
    ),
    ThemedMilestone(
      name: "Cell Keeper",
      flavor: "Two weeks; entrusted with keeping a monastic cell in order.",
    ),
    ThemedMilestone(
      name: "Three-Week Retreat",
      flavor: "The traditional length of a transformative spiritual retreat.",
    ),
    ThemedMilestone(
      name: "First Moon Fast",
      flavor:
          "One complete lunar fast — mind and body intact through all of it.",
    ),
    ThemedMilestone(
      name: "Inner Stillness",
      flavor: "45 days; the inner noise begins, at last, to fall silent.",
    ),
    ThemedMilestone(
      name: "Two Months Practice",
      flavor:
          "Two months of daily prayer, meditation, and practice — unbroken.",
    ),
    ThemedMilestone(
      name: "Professed Monk",
      flavor:
          "90 days; formal profession of monastic vows before the community.",
    ),
    ThemedMilestone(
      name: "Illuminated",
      flavor:
          "100 days; the light of clarity begins to shine unmistakably from within.",
    ),
    ThemedMilestone(
      name: "Senior Novice",
      flavor:
          "Six months; now guiding newer novices on the path you have walked.",
    ),
    ThemedMilestone(
      name: "Contemplative",
      flavor:
          "Nine months of unbroken contemplative practice. The mind is quiet.",
    ),
    ThemedMilestone(
      name: "Year of Grace",
      flavor: "A full year of grace. The inner transformation is now complete.",
    ),
    ThemedMilestone(
      name: "Acolyte",
      flavor: "500 days serving the sacred fire and the temple community.",
    ),
    ThemedMilestone(
      name: "Father Superior",
      flavor:
          "Eighteen months; leading a monastic house as Father or Mother Superior.",
    ),
    ThemedMilestone(
      name: "Abbot",
      flavor:
          "Two years; elevated to Abbot of the Abbey. The community looks to you.",
    ),
    ThemedMilestone(
      name: "Hermit Scholar",
      flavor: "Three years; a scholar of the sacred texts, sought for counsel.",
    ),
    ThemedMilestone(
      name: "Mystic",
      flavor:
          "Four years; experiencing the mystical union. Words cannot describe it.",
    ),
    ThemedMilestone(
      name: "Saint in Life",
      flavor:
          "Five years; revered as a living saint. Others pilgrimage to find you.",
    ),
    ThemedMilestone(
      name: "Enlightened",
      flavor:
          "Seven years; full enlightenment attained. The veil has dissolved.",
    ),
    ThemedMilestone(
      name: "Bodhisattva",
      flavor:
          "A decade; one who delays nirvana to return and help all others awaken.",
    ),
  ],
  "phoenix": [
    ThemedMilestone(
      name: "Ash",
      flavor: "Reduced to ash. The fire has consumed the old self.",
    ),
    ThemedMilestone(
      name: "Ember",
      flavor: "A tiny ember glows beneath the ash. Do not let it die.",
    ),
    ThemedMilestone(
      name: "First Flame",
      flavor: "Seven days; the flame catches and holds through the wind.",
    ),
    ThemedMilestone(
      name: "Kindling",
      flavor: "Two weeks; enough heat to kindle a real and lasting fire.",
    ),
    ThemedMilestone(
      name: "Warming Fire",
      flavor: "21 days; the fire now provides warmth, not just light.",
    ),
    ThemedMilestone(
      name: "Steady Burn",
      flavor: "One month; the fire burns steadily without constant tending.",
    ),
    ThemedMilestone(
      name: "Rising Smoke",
      flavor: "45 days; the smoke signal of your rebirth is visible for miles.",
    ),
    ThemedMilestone(
      name: "Bright Flame",
      flavor:
          "Two months; the flame is bright enough now to guide others through the dark.",
    ),
    ThemedMilestone(
      name: "Blazing",
      flavor: "90 days; a full blazing fire. Your light is felt from far away.",
    ),
    ThemedMilestone(
      name: "Inferno",
      flavor: "100 days; the inferno of transformation roars at full power.",
    ),
    ThemedMilestone(
      name: "Rebirth Begun",
      flavor: "Six months; feathers beginning to emerge from the flame.",
    ),
    ThemedMilestone(
      name: "New Wings",
      flavor:
          "Nine months; wings fully formed, ready to unfurl and catch the thermal.",
    ),
    ThemedMilestone(
      name: "First Flight",
      flavor: "A year; the Phoenix spreads its wings and takes flight. Soar.",
    ),
    ThemedMilestone(
      name: "Sky Sovereign",
      flavor: "500 days gliding through the high thermals of freedom.",
    ),
    ThemedMilestone(
      name: "Touched the Sun",
      flavor:
          "18 months; like Icarus but stronger — you reached the sun and were not burned.",
    ),
    ThemedMilestone(
      name: "Full Phoenix",
      flavor: "Two years; the complete Phoenix transformation cycle fulfilled.",
    ),
    ThemedMilestone(
      name: "Eternal Flame",
      flavor:
          "Three years; your flame can now never be extinguished by any storm.",
    ),
    ThemedMilestone(
      name: "Fire Keeper",
      flavor: "Four years; you now carry fire for others lost in the dark.",
    ),
    ThemedMilestone(
      name: "Constellation",
      flavor: "Five years; your fire is now a star visible in the sky.",
    ),
    ThemedMilestone(
      name: "Solar",
      flavor: "Seven years; you have become a star. Warmth and light for all.",
    ),
    ThemedMilestone(
      name: "Cosmic Fire",
      flavor: "A decade; you are the fire at the centre of existence itself.",
    ),
  ],
  "animals": [
    ThemedMilestone(
      name: "Tardigrade",
      flavor: "Virtually indestructible. Surviving extreme conditions.",
    ),
    ThemedMilestone(
      name: "Worker Ant",
      flavor: "Carrying many times your own weight in silence.",
    ),
    ThemedMilestone(
      name: "Honeybee",
      flavor: "Organized, focused, and building something sweet day by day.",
    ),
    ThemedMilestone(
      name: "Field Mouse",
      flavor: "Nimble, quick, and learning to avoid the traps of life.",
    ),
    ThemedMilestone(
      name: "Bullfrog",
      flavor:
          "Leaping forward. A complete metamorphosis from the old tadpole self.",
    ),
    ThemedMilestone(
      name: "Barn Owl",
      flavor: "Silent flyer. Gaining clear vision in the darkest hours.",
    ),
    ThemedMilestone(
      name: "Red Fox",
      flavor: "Cunning and adaptable. Outsmarting the old triggers.",
    ),
    ThemedMilestone(
      name: "Grey Wolf",
      flavor: "Loyal to the pack of self-improvement. Stronger, wiser.",
    ),
    ThemedMilestone(
      name: "Golden Eagle",
      flavor: "Soaring above the noise. Master of the high winds.",
    ),
    ThemedMilestone(
      name: "Cheetah",
      flavor: "Fast-moving. Quickly leaving the past behind.",
    ),
    ThemedMilestone(
      name: "Jaguar",
      flavor: "Stalking the jungle of life with absolute grace and stealth.",
    ),
    ThemedMilestone(
      name: "Siberian Tiger",
      flavor: "A solitary powerhouse. A majestic force in the cold forest.",
    ),
    ThemedMilestone(
      name: "Grizzly Bear",
      flavor:
          "Unstoppable mass. A symbol of raw power and hibernation-strength.",
    ),
    ThemedMilestone(
      name: "Gorilla",
      flavor:
          "Gentle giant. Possessing massive strength guided by intelligence.",
    ),
    ThemedMilestone(
      name: "Nile Crocodile",
      flavor:
          "Submerged patience. Striking when the time is right, master of wait.",
    ),
    ThemedMilestone(
      name: "Hippo",
      flavor: "An absolute fortress. Dominating your territory without fear.",
    ),
    ThemedMilestone(
      name: "Great White",
      flavor: "Top predator. The apex hunter of your old habits.",
    ),
    ThemedMilestone(
      name: "African Elephant",
      flavor: "Infinite memory. Never forgetting the lessons of the past.",
    ),
    ThemedMilestone(
      name: "Blue Whale",
      flavor: "Gentle ocean giant. A massive presence, calm and steady.",
    ),
    ThemedMilestone(
      name: "Tyrannosaurus Rex",
      flavor: "Apex of prehistoric history. A thunderous roar of victory.",
    ),
    ThemedMilestone(
      name: "Mythical Dragon",
      flavor: "Transcended nature. Breathing fire, flying above all realms.",
    ),
  ],
  "pokemon": [
    ThemedMilestone(
      name: "Magikarp",
      flavor: "Splashing. It seems useless now, but the potential is massive.",
    ),
    ThemedMilestone(
      name: "Caterpie",
      flavor: "Starting small. Crawling in the grass, but cocoon is coming.",
    ),
    ThemedMilestone(
      name: "Weedle",
      flavor: "Slightly poisonous to the past. String shot of discipline.",
    ),
    ThemedMilestone(
      name: "Rattata",
      flavor: "Quick attack. Running away from immediate danger.",
    ),
    ThemedMilestone(
      name: "Zubat",
      flavor: "Navigating the dark caves by sound and instinct alone.",
    ),
    ThemedMilestone(
      name: "Pikachu",
      flavor: "Static energy. A spark of electricity starting the engine.",
    ),
    ThemedMilestone(
      name: "Bulbasaur",
      flavor: "Seed planted. The vine whip of progress is growing.",
    ),
    ThemedMilestone(
      name: "Squirtle",
      flavor: "Water gun. Washing away the old dirt of habits.",
    ),
    ThemedMilestone(
      name: "Charmander",
      flavor: "A tiny flame on the tail. Keep it burning through the rain.",
    ),
    ThemedMilestone(
      name: "Eevee",
      flavor: "Infinite potential. Ready to evolve into any style of life.",
    ),
    ThemedMilestone(
      name: "Machoke",
      flavor: "Physical training paying off. Belt of restraint earned.",
    ),
    ThemedMilestone(
      name: "Kadabra",
      flavor: "Mind over matter. Psychic focus sharpening.",
    ),
    ThemedMilestone(
      name: "Gyarados",
      flavor:
          "Metamorphosis complete! Thrashing the old triggers with Dragon Rage.",
    ),
    ThemedMilestone(
      name: "Gengar",
      flavor:
          "Ghostly immunities. Walking through old walls like they aren't there.",
    ),
    ThemedMilestone(
      name: "Dragonite",
      flavor:
          "Gentle but incredibly powerful. Flying around the world in hours.",
    ),
    ThemedMilestone(
      name: "Charizard",
      flavor:
          "Flamethrower of determination. Flying high, tail burning bright.",
    ),
    ThemedMilestone(
      name: "Mew",
      flavor: "Pure and rare. Containing the DNA of all progress.",
    ),
    ThemedMilestone(
      name: "Mewtwo",
      flavor: "Awakened mind. An absolute psychic force of willpower.",
    ),
    ThemedMilestone(
      name: "Rayquaza",
      flavor: "High in the ozone layer. Calmly eating the meteors of relapse.",
    ),
    ThemedMilestone(
      name: "Giratina",
      flavor:
          "Ruling the distortion world. Master of alternate planes of focus.",
    ),
    ThemedMilestone(
      name: "Arceus",
      flavor: "The Creator. You have built a completely new universe.",
    ),
  ],
  "jjk": [
    ThemedMilestone(
      name: "Fly Head",
      flavor: "Weakest cursed spirit. Easily exorcised by a beginner.",
    ),
    ThemedMilestone(
      name: "Kasumi Miwa",
      flavor: "Just trying her best. Simple Domain is active.",
    ),
    ThemedMilestone(
      name: "Mai Zenin",
      flavor: "Constructing one bullet a day. Limited but determined.",
    ),
    ThemedMilestone(
      name: "Nobara",
      flavor: "Resonating with the soul. Driving nails through the past.",
    ),
    ThemedMilestone(
      name: "Megumi",
      flavor: "Summoning the Divine Dog. Stepping into the shadows.",
    ),
    ThemedMilestone(
      name: "Panda",
      flavor: "Not a panda! Three cores fighting together in harmony.",
    ),
    ThemedMilestone(
      name: "Toge Inumaki",
      flavor: "Cursed speech: 'Don't move!' Restraining the triggers.",
    ),
    ThemedMilestone(
      name: "Kento Nanami",
      flavor:
          "Overtime begins now. Ratio technique finding the critical point.",
    ),
    ThemedMilestone(
      name: "Aoi Todo",
      flavor: "Boogie Woogie! Swapping places with the triggers instantly.",
    ),
    ThemedMilestone(
      name: "Suguru Geto",
      flavor: "Cursed spirit manipulation. Swallowing the poison to grow.",
    ),
    ThemedMilestone(
      name: "Mei Mei",
      flavor: "Black Bird Manipulation. Making the crow die for success.",
    ),
    ThemedMilestone(
      name: "Maki (Awakened)",
      flavor: "Zero cursed energy. Absolute physical gift. Steel muscles.",
    ),
    ThemedMilestone(
      name: "Choso",
      flavor: "Supernova! Protecting the brotherhood of your future self.",
    ),
    ThemedMilestone(
      name: "Toji Fushiguro",
      flavor: "The Heavenly Restriction. Exorcising gods with raw steel.",
    ),
    ThemedMilestone(
      name: "Mahito",
      flavor: "Idle Transfiguration. Rewriting the shape of your soul.",
    ),
    ThemedMilestone(
      name: "Jogo",
      flavor: "Disaster flames. Melting the opposition with volcano speed.",
    ),
    ThemedMilestone(
      name: "Suguru Geto",
      flavor: "Playful Cloud master. Commanding the curse army.",
    ),
    ThemedMilestone(
      name: "Yuta Okkotsu",
      flavor: "Pure Love. Infinite cursed energy bound to resolve.",
    ),
    ThemedMilestone(
      name: "Kenjaku",
      flavor: "Cunning mastermind. Playing the thousand-year long game.",
    ),
    ThemedMilestone(
      name: "Ryomen Sukuna",
      flavor: "Malevolent Shrine. Cutting through all doubts and cravings.",
    ),
    ThemedMilestone(
      name: "Satoru Gojo",
      flavor: "Throughout Heaven and Earth, you alone are the honored one.",
    ),
  ],
  "onepiece": [
    ThemedMilestone(
      name: "East Blue Coby",
      flavor: "Weak, crying, but finally stating your true dream.",
    ),
    ThemedMilestone(
      name: "Usopp",
      flavor: "A liar no more. The sniper who stands his ground.",
    ),
    ThemedMilestone(
      name: "Buggy the Clown",
      flavor: "Split-Split power. Surviving by splitting from issues.",
    ),
    ThemedMilestone(
      name: "Nami",
      flavor: "Navigating the weather. Drawing the map of your new life.",
    ),
    ThemedMilestone(
      name: "Tony Chopper",
      flavor: "Monster Point! Healing the inner sickness with medical resolve.",
    ),
    ThemedMilestone(
      name: "Brook",
      flavor: "Yo-ho-ho! Dead but alive. Soul solid and singing.",
    ),
    ThemedMilestone(
      name: "Franky",
      flavor: "SUPER! Built from scrap metal, running on pure cola.",
    ),
    ThemedMilestone(
      name: "Nico Robin",
      flavor: "I want to live! Demonic limbs blooming to protect you.",
    ),
    ThemedMilestone(
      name: "Jinbe",
      flavor: "Fishman Karate. The shield of honor and loyalty.",
    ),
    ThemedMilestone(
      name: "Crocodile",
      flavor: "Sands of time. Drying out the toxic swamps of life.",
    ),
    ThemedMilestone(
      name: "Portgas D. Ace",
      flavor: "Fire Fist! Burning hot and leaving a legacy of warmth.",
    ),
    ThemedMilestone(
      name: "Trafalgar Law",
      flavor:
          "ROOM! Operating on the details of your habits with surgical precision.",
    ),
    ThemedMilestone(
      name: "Eustass Kid",
      flavor: "Assigning magnetic force. Repelling the negative elements.",
    ),
    ThemedMilestone(
      name: "Vinsmoke Sanji",
      flavor: "Diable Jambe! Fire kicks of passion and elite service.",
    ),
    ThemedMilestone(
      name: "Roronoa Zoro",
      flavor: "Three-Sword Style: Ichidai Sanzen Daisen Sekai! Ashura mode.",
    ),
    ThemedMilestone(
      name: "Luffy Gear 4",
      flavor: "Bounce-man. Bouncing back from adversity with rubber armor.",
    ),
    ThemedMilestone(
      name: "Luffy Gear 5",
      flavor: "Joyboy returns! The drum of liberation beating in your chest.",
    ),
    ThemedMilestone(
      name: "Shanks",
      flavor: "Divine Departure. A conqueror's haki that stops wars.",
    ),
    ThemedMilestone(
      name: "Kaido",
      flavor: "The strongest creature. A dragon scale that cannot be pierced.",
    ),
    ThemedMilestone(
      name: "Whitebeard",
      flavor: "The man who stands before the ocean. No scars on the back.",
    ),
    ThemedMilestone(
      name: "Gol D. Roger",
      flavor:
          "Wealth, fame, power — the world is yours. You found the One Piece.",
    ),
  ],
  "naruto": [
    ThemedMilestone(
      name: "Konohamaru",
      flavor: "Sexy Jutsu master. Learning the basics of the shadow clone.",
    ),
    ThemedMilestone(
      name: "Kiba Inuzuka",
      flavor: "Fang over fang. Wild instincts running the show.",
    ),
    ThemedMilestone(
      name: "Rock Lee",
      flavor:
          "Primary Lotus! Unlocking the gates of pure, unadulterated effort.",
    ),
    ThemedMilestone(
      name: "Sakura (Shippuden)",
      flavor: "Chakra control. Healing the wounds and building strength.",
    ),
    ThemedMilestone(
      name: "Hinata Hyuga",
      flavor: "Gentle Step Twin Lion Fists. Quiet but unbreakable resolve.",
    ),
    ThemedMilestone(
      name: "Neji Hyuga",
      flavor: "Eight Trigrams Sixty-Four Palms. Defending your blind spot.",
    ),
    ThemedMilestone(
      name: "Shikamaru",
      flavor: "Shadow possession. High-IQ strategy mapping the path.",
    ),
    ThemedMilestone(
      name: "Gaara",
      flavor: "Shield of Sand. Auto-defense against all incoming triggers.",
    ),
    ThemedMilestone(
      name: "Kakashi Hatake",
      flavor: "Lightning Blade. Piercing the darkness with copy-wheel vision.",
    ),
    ThemedMilestone(
      name: "Guy (Gates Closed)",
      flavor: "Dynamic Entry! The green beast of youth is roaring.",
    ),
    ThemedMilestone(
      name: "Jiraiya",
      flavor: "Sage Mode Toad Summoning. Writing the tale of a gutsy shinobi.",
    ),
    ThemedMilestone(
      name: "Orochimaru",
      flavor: "Rebirth through shedding the skin. Survival at all costs.",
    ),
    ThemedMilestone(
      name: "Tsunade",
      flavor: "Mitotic Regeneration. Instantly healing from all damage.",
    ),
    ThemedMilestone(
      name: "Itachi Uchiha",
      flavor: "Tsukuyomi. Controlling the perception of time and pain.",
    ),
    ThemedMilestone(
      name: "Pain",
      flavor: "Almighty Push! Pushing away the old world to create the new.",
    ),
    ThemedMilestone(
      name: "Minato Namikaze",
      flavor: "Flying Raijin. Teleporting past the triggers instantly.",
    ),
    ThemedMilestone(
      name: "Obito (Ten-Tails)",
      flavor: "Truth-Seeking Orbs. Erasing the past to build a dream.",
    ),
    ThemedMilestone(
      name: "Madara (Six Paths)",
      flavor: "Infinite Tsukuyomi. A planetary scale of absolute dominance.",
    ),
    ThemedMilestone(
      name: "Sasuke (Rinnegan)",
      flavor: "Indra's Arrow. Perfect Susanoo slicing through mountains.",
    ),
    ThemedMilestone(
      name: "Naruto (Hokage)",
      flavor: "Baryon Mode. The peak of natural energy, saving the village.",
    ),
    ThemedMilestone(
      name: "Sage of Six Paths",
      flavor: "Ancestor of Chakra. The absolute origin of energy and peace.",
    ),
  ],
  "ben10": [
    ThemedMilestone(
      name: "Grey Matter",
      flavor: "Tiny but incredibly smart. Finding the weak point of habits.",
    ),
    ThemedMilestone(
      name: "Wildmutt",
      flavor: "No eyes, but absolute sensory tracking. Smelling the danger.",
    ),
    ThemedMilestone(
      name: "Ripjaws",
      flavor: "Navigating the deep waters of emotion without drowning.",
    ),
    ThemedMilestone(
      name: "Ghostfreak",
      flavor: "Phasing through solid walls. Invisible to the past.",
    ),
    ThemedMilestone(
      name: "Stinkfly",
      flavor: "Spitting slime to trap the immediate cravings.",
    ),
    ThemedMilestone(
      name: "Heatblast",
      flavor: "Pyrokinesis. Melting the cold chains of dependency.",
    ),
    ThemedMilestone(
      name: "Four Arms",
      flavor: "Raw physical power. Lifting the heavy burdens of life.",
    ),
    ThemedMilestone(
      name: "XLR8",
      flavor: "Frictionless speed. Moving faster than the speed of temptation.",
    ),
    ThemedMilestone(
      name: "Diamondhead",
      flavor: "Crystal shield. Harder than diamonds, reflecting attacks.",
    ),
    ThemedMilestone(
      name: "Upgrade",
      flavor: "Merging with technology to upgrade your daily systems.",
    ),
    ThemedMilestone(
      name: "Cannonbolt",
      flavor: "Rolling thunder. Bouncing off the obstacles with armor.",
    ),
    ThemedMilestone(
      name: "Wildvine",
      flavor: "Sprouting seeds of growth. Deep roots in the ground.",
    ),
    ThemedMilestone(
      name: "Swampfire",
      flavor: "Regenerating limbs in seconds. Fire blast of renewal.",
    ),
    ThemedMilestone(
      name: "Humungousaur",
      flavor: "Growing to massive sizes. Stepping over the problems.",
    ),
    ThemedMilestone(
      name: "Big Chill",
      flavor: "Freezing the cravings in their tracks. Intangible presence.",
    ),
    ThemedMilestone(
      name: "Chromastone",
      flavor: "Absorbing the negative energy and firing it back as lasers.",
    ),
    ThemedMilestone(
      name: "Ultimate Echo Echo",
      flavor: "Sonic doom! Vibrating the old pathways to pieces.",
    ),
    ThemedMilestone(
      name: "Feedback",
      flavor: "Absorbing the Big Bang of relapse energy and redirecting it.",
    ),
    ThemedMilestone(
      name: "Atomix",
      flavor: "Nuclear fusion of discipline. Unstoppable bright light.",
    ),
    ThemedMilestone(
      name: "Way Big",
      flavor: "Cosmic giant. Standing tall above the city of issues.",
    ),
    ThemedMilestone(
      name: "Alien X",
      flavor: "Motion table passed. Total control over reality itself.",
    ),
  ],
  "aot": [
    ThemedMilestone(
      name: "Pure Titan",
      flavor: "Mindless wandering, but the potential to awaken is inside.",
    ),
    ThemedMilestone(
      name: "Connie Springer",
      flavor: "Fast learner. Standing up for the family.",
    ),
    ThemedMilestone(
      name: "Sasha Blouse",
      flavor: "Wild instincts. Sniffing out the target. Potatoes!",
    ),
    ThemedMilestone(
      name: "Marco Bott",
      flavor: "The good leader. Finding the middle ground in struggle.",
    ),
    ThemedMilestone(
      name: "Jean Kirstein",
      flavor: "A realist who chooses to fight. Seeing the truth clearly.",
    ),
    ThemedMilestone(
      name: "Hange Zoe",
      flavor: "Scientific curiosity about the enemy. Understanding triggers.",
    ),
    ThemedMilestone(
      name: "Erwin Smith",
      flavor: "My soldiers, rage! Leading the charge into the unknown.",
    ),
    ThemedMilestone(
      name: "Ymir (Jaw)",
      flavor: "Nasty bite. Quick action to save the friends.",
    ),
    ThemedMilestone(
      name: "Historia Reiss",
      flavor: "True queen. Choosing your own name and destiny.",
    ),
    ThemedMilestone(
      name: "Bertholdt (Colossal)",
      flavor: "Steam blast of massive change. Standing tall.",
    ),
    ThemedMilestone(
      name: "Reiner (Armored)",
      flavor: "Unbreakable skin. Charging through the gates of doubt.",
    ),
    ThemedMilestone(
      name: "Annie (Female)",
      flavor: "Elite martial arts. Crystallizing to protect the heart.",
    ),
    ThemedMilestone(
      name: "Zeke (Beast)",
      flavor: "Perfect pitch throwing. Controlling the titan field.",
    ),
    ThemedMilestone(
      name: "Falco (Jaw)",
      flavor: "Taking flight. A bird soaring above the walls of the world.",
    ),
    ThemedMilestone(
      name: "Armin (Colossal)",
      flavor: "Strategic mastermind. The nuke of massive transformation.",
    ),
    ThemedMilestone(
      name: "Mikasa Ackerman",
      flavor: "You are strong. Protecting the home with steel blades.",
    ),
    ThemedMilestone(
      name: "Levi Ackerman",
      flavor:
          "Spinning blades of death. Clearing the forest of issues in seconds.",
    ),
    ThemedMilestone(
      name: "Eren (Attack)",
      flavor: "Keep moving forward. Fight, fight, fight.",
    ),
    ThemedMilestone(
      name: "Eren (War Hammer)",
      flavor: "Creating spikes of discipline from the ground.",
    ),
    ThemedMilestone(
      name: "Eren (Founding)",
      flavor: "The Rumbling. Flattening the old toxic landscape completely.",
    ),
    ThemedMilestone(
      name: "Ymir Fritz",
      flavor: "Free from the paths. The absolute creator of the coordinate.",
    ),
  ],
  "bleach": [
    ThemedMilestone(
      name: "Teddy Kon",
      flavor: "Trapped in a plush toy, but still complaining and running.",
    ),
    ThemedMilestone(
      name: "Keigo Asano",
      flavor:
          "Loud, running away, but somehow surviving the spiritual pressure.",
    ),
    ThemedMilestone(
      name: "Tatsuki Arisawa",
      flavor: "Kicking the standard hollows with raw human spirit.",
    ),
    ThemedMilestone(
      name: "Chad",
      flavor: "Right Arm of the Giant. A shield for the weak.",
    ),
    ThemedMilestone(
      name: "Uryu Ishida",
      flavor: "Heilig Bogen. A rain of arrows from the sky.",
    ),
    ThemedMilestone(
      name: "Rukia Kuchiki",
      flavor: "Sode no Shirayuki. Freezing the past in white ribbons.",
    ),
    ThemedMilestone(
      name: "Renji Abarai",
      flavor: "Howl, Zabimaru! Roaring through the battle.",
    ),
    ThemedMilestone(
      name: "Ikkaku",
      flavor: "Lucky Dance. Bankai Ryumon Hozukimaru!",
    ),
    ThemedMilestone(
      name: "Izuru Kira",
      flavor:
          "Wabisuke. Making the weight of the past double with every strike.",
    ),
    ThemedMilestone(
      name: "Rangiku",
      flavor: "Haineko. Turning the sword into ash to choke the triggers.",
    ),
    ThemedMilestone(
      name: "Toshiro Hitsugaya",
      flavor: "Hyorinmaru. The ice dragon freezing the weather.",
    ),
    ThemedMilestone(
      name: "Byakuya Kuchiki",
      flavor:
          "Senbonzakura Kageyoshi. A million petals slicing through doubts.",
    ),
    ThemedMilestone(
      name: "Kenpachi Zaraki",
      flavor: "Removing the eye patch. Raw, unbridled spiritual power.",
    ),
    ThemedMilestone(
      name: "Kisuke Urahara",
      flavor: "Benihime. The scientist who has a plan for everything.",
    ),
    ThemedMilestone(
      name: "Yamamoto",
      flavor: "Zanka no Tachi. A flame that dries up the entire soul society.",
    ),
    ThemedMilestone(
      name: "Sosuke Aizen",
      flavor:
          "Since when were you under the impression you weren't sober? Kyoka Suigetsu.",
    ),
    ThemedMilestone(
      name: "Ichigo (Shikai)",
      flavor: "Zangetsu. Tearing down the old sky of rain.",
    ),
    ThemedMilestone(
      name: "Ichigo (Bankai)",
      flavor: "Tensa Zangetsu. Black speed slicing the immediate threats.",
    ),
    ThemedMilestone(
      name: "Ichigo (Hollow)",
      flavor: "Vasto Lorde. The instinct to survive at all costs.",
    ),
    ThemedMilestone(
      name: "Ichigo (Mugetsu)",
      flavor: "Saigo no Getsuga Tensho. Becoming getsuga itself.",
    ),
    ThemedMilestone(
      name: "Yhwach",
      flavor: "The Almighty. Seeing and rewriting all futures.",
    ),
  ],
  "mha": [
    ThemedMilestone(
      name: "Minoru Mineta",
      flavor: "Sticky balls of panic. Throwing them and running away.",
    ),
    ThemedMilestone(
      name: "Kyoka Jiro",
      flavor: "Heartbeat Distortion. Vibrating the negative elements out.",
    ),
    ThemedMilestone(
      name: "Denki Kaminari",
      flavor: "1.3 Million Volts! Brain short-circuited but enemy down.",
    ),
    ThemedMilestone(
      name: "Tsuyu Asui",
      flavor: "Frog form. Highly reliable in any watery situation.",
    ),
    ThemedMilestone(
      name: "Ochaco Uraraka",
      flavor: "Zero Gravity. Making the heavy problems weightless.",
    ),
    ThemedMilestone(
      name: "Tenya Iida",
      flavor: "Recipro Burst! Speeding past the danger zone.",
    ),
    ThemedMilestone(
      name: "Eijiro Kirishima",
      flavor: "Red Riot Unbreakable! A shield of pure hardened rock.",
    ),
    ThemedMilestone(
      name: "Shoto Todoroki",
      flavor: "Half-cold, half-hot. A wall of ice and a wave of fire.",
    ),
    ThemedMilestone(
      name: "Katsuki Bakugo",
      flavor: "Howitzer Impact! Blasting the triggers to dust.",
    ),
    ThemedMilestone(
      name: "Midoriya (5%)",
      flavor: "Full Cowling. The first sparks of One For All.",
    ),
    ThemedMilestone(
      name: "Midoriya (20%)",
      flavor: "Delaware Smash! Air pressure shooting down the target.",
    ),
    ThemedMilestone(
      name: "Hawks",
      flavor: "Fierce Wings. Sending feathers of support to the team.",
    ),
    ThemedMilestone(
      name: "Best Jeanist",
      flavor: "Taming the wild threads of life with tailor precision.",
    ),
    ThemedMilestone(
      name: "Endeavor",
      flavor: "Prominence Burn! Fire that consumes all hesitation.",
    ),
    ThemedMilestone(
      name: "Tomura (Decay)",
      flavor: "Decaying the old city of structures with a single touch.",
    ),
    ThemedMilestone(
      name: "Midoriya (Shoot)",
      flavor: "Using the legs to kick through the adversity.",
    ),
    ThemedMilestone(
      name: "Nine",
      flavor: "Storm controller. Summoning lightning from the sky.",
    ),
    ThemedMilestone(
      name: "Tomura (AFO)",
      flavor: "Stealing the powers of the past to build a new empire.",
    ),
    ThemedMilestone(
      name: "Midoriya (100%)",
      flavor: "Eri on the back. Rewriting time to stay in peak state.",
    ),
    ThemedMilestone(
      name: "All Might (Prime)",
      flavor: "United States of Smash! A punch that changes the weather.",
    ),
    ThemedMilestone(
      name: "Star and Stripe",
      flavor: "New Order. Rewriting the laws of the universe by speaking.",
    ),
  ],
  "vinland": [
    ThemedMilestone(
      name: "Leif Erikson",
      flavor: "The traveler. Talking about a land far away, Vinland.",
    ),
    ThemedMilestone(
      name: "Willibald",
      flavor: "The priest searching for the true meaning of love.",
    ),
    ThemedMilestone(
      name: "Canute (Prince)",
      flavor: "Scared, hiding behind the guards, silent.",
    ),
    ThemedMilestone(
      name: "Ragnar",
      flavor: "The protector. Sacrificing everything for the prince.",
    ),
    ThemedMilestone(
      name: "Torgrim",
      flavor: "The warrior who chooses when to yield to survive.",
    ),
    ThemedMilestone(
      name: "Halfdan",
      flavor: "The iron master. Keeping the contracts strictly locked.",
    ),
    ThemedMilestone(
      name: "Sigurd",
      flavor: "Chasing the runaway wife, learning what pride means.",
    ),
    ThemedMilestone(
      name: "Bjorn (Berserk)",
      flavor: "Eating the mushroom. Raw, wild fury on the battlefield.",
    ),
    ThemedMilestone(
      name: "Garm",
      flavor: "The wild dog who loves the spear and the fight.",
    ),
    ThemedMilestone(
      name: "Askellad",
      flavor: "The master manipulator. Playing the chessboard of kings.",
    ),
    ThemedMilestone(
      name: "Thorfinn (Teen)",
      flavor: "A heart filled with rage, dual daggers striking in the dark.",
    ),
    ThemedMilestone(
      name: "Thorfinn (Slave)",
      flavor: "Working the soil. Finding the quiet in the forest.",
    ),
    ThemedMilestone(
      name: "Snake",
      flavor: "The protector of the farm. Quick blade, sharp eye.",
    ),
    ThemedMilestone(
      name: "Canute (King)",
      flavor: "The crown on the head. Leading the North Sea Empire.",
    ),
    ThemedMilestone(
      name: "Thorfinn (Pacifist)",
      flavor: "I have no enemies. Sparing the opponent, holding the fist.",
    ),
    ThemedMilestone(
      name: "Thorkell the Tall",
      flavor: "Laughing in the battle. Throwing logs like spears.",
    ),
    ThemedMilestone(
      name: "Thors (Troll)",
      flavor: "A true warrior needs no sword. Sinking the fleet barehanded.",
    ),
    ThemedMilestone(
      name: "Ylva",
      flavor: "Working the fish, carrying the wood. Unbreakable home pillar.",
    ),
    ThemedMilestone(
      name: "Helga",
      flavor: "The quiet strength. The mother who understands the wanderer.",
    ),
    ThemedMilestone(
      name: "Floki",
      flavor: "The plotter. Commanding the Jomsvikings from the shadows.",
    ),
    ThemedMilestone(
      name: "Vinland Dream",
      flavor: "The golden fields of peace. A land where no swords are needed.",
    ),
  ],
  "demonslayer": [
    ThemedMilestone(
      name: "Murata",
      flavor: "The ultimate survivor. Somehow gets through every mission.",
    ),
    ThemedMilestone(
      name: "Aoi Kanzaki",
      flavor: "Cooking, cleaning, and training behind the lines.",
    ),
    ThemedMilestone(
      name: "Genya",
      flavor: "Eating the demon to gain the strength. Scraping by.",
    ),
    ThemedMilestone(
      name: "Kanao Tsuyuri",
      flavor: "Flipping the coin. Awakening the flower breathing.",
    ),
    ThemedMilestone(
      name: "Zenitsu Agatsuma",
      flavor: "Thunder Breathing First Form: Thunderclap and Flash! Six Fold!",
    ),
    ThemedMilestone(
      name: "Inosuke",
      flavor: "Beast Breathing. Charging headfirst with dual jagged swords.",
    ),
    ThemedMilestone(
      name: "Tanjiro (Water)",
      flavor: "Water Wheel. Finding the thread of opening in the dark.",
    ),
    ThemedMilestone(
      name: "Shinobu Kocho",
      flavor: "Wisteria poison. A butterfly sting that kills from within.",
    ),
    ThemedMilestone(
      name: "Tengen Uzui",
      flavor: "Flashy! Sound breathing slicing the night.",
    ),
    ThemedMilestone(
      name: "Mitsuri Kanroji",
      flavor: "Love breathing. Slicing with the flexible whip sword.",
    ),
    ThemedMilestone(
      name: "Obanai Iguro",
      flavor: "Serpent breathing. Slinking past the defenses.",
    ),
    ThemedMilestone(
      name: "Muichiro Tokito",
      flavor: "Mist breathing. Lost in the clouds, but striking with speed.",
    ),
    ThemedMilestone(
      name: "Rengoku Kyojuro",
      flavor: "Set your heart ablaze! Flame Tiger roaring in the night.",
    ),
    ThemedMilestone(
      name: "Sanemi",
      flavor: "Wind breathing. Slicing the air with scars and fury.",
    ),
    ThemedMilestone(
      name: "Giyu Tomioka",
      flavor: "Dead Calm. Total stillness that nullifies all attacks.",
    ),
    ThemedMilestone(
      name: "Akaza",
      flavor: "Compass Needle. A martial artist seeking the peak of strength.",
    ),
    ThemedMilestone(
      name: "Doma",
      flavor: "Ice sculptures of freezing poison. Golden fans spinning.",
    ),
    ThemedMilestone(
      name: "Kokushibo",
      flavor: "Moon breathing. Crescent blades filling the entire room.",
    ),
    ThemedMilestone(
      name: "Tanjiro (Sun)",
      flavor: "Hinokami Kagura! Dance of the Fire God.",
    ),
    ThemedMilestone(
      name: "Muzan Kibutsuji",
      flavor:
          "The original demon. Whip limbs tearing through the slayer corps.",
    ),
    ThemedMilestone(
      name: "Yoriichi Tsugikuni",
      flavor: "The first breath. Slicing Muzan into 1500 pieces in one second.",
    ),
  ],
  "fma": [
    ThemedMilestone(
      name: "Yoki",
      flavor: "A corrupt official. Easily tricked, running for life.",
    ),
    ThemedMilestone(
      name: "Nina & Alexander",
      flavor: "A tragic combination, but the seed of research is sown.",
    ),
    ThemedMilestone(
      name: "Kain Fuery",
      flavor: "Setting up the communications. The support team.",
    ),
    ThemedMilestone(
      name: "Vato Falman",
      flavor: "The walking database. Remembering every detail.",
    ),
    ThemedMilestone(
      name: "Riza Hawkeye",
      flavor: "The sniper who never misses. Watching the back of the flame.",
    ),
    ThemedMilestone(
      name: "Jean Havoc",
      flavor: "Cool under pressure. Smoking a cigarette through the mess.",
    ),
    ThemedMilestone(
      name: "Winry Rockbell",
      flavor: "Wrench in hand. Upgrading the automail of progress.",
    ),
    ThemedMilestone(
      name: "Ling Yao",
      flavor: "Hungry prince. Seeking the secret of immortality.",
    ),
    ThemedMilestone(
      name: "Lan Fan",
      flavor: "Automail blade. Sacrificing the arm for the master.",
    ),
    ThemedMilestone(
      name: "Alphonse Elric",
      flavor: "An empty suit of armor, but a heart of gold.",
    ),
    ThemedMilestone(
      name: "Edward Elric",
      flavor: "The Fullmetal Alchemist. Transmuting without a circle.",
    ),
    ThemedMilestone(
      name: "Olivier Armstrong",
      flavor: "Northern wall of Briggs. Cold, sharp, and absolute.",
    ),
    ThemedMilestone(
      name: "Alex Armstrong",
      flavor:
          "Passed down the Armstrong line for generations! Sparkling muscles.",
    ),
    ThemedMilestone(
      name: "Izumi Curtis",
      flavor: "A housewife! Taming the wild beasts and transmuting elements.",
    ),
    ThemedMilestone(
      name: "Roy Mustang",
      flavor: "The Flame Alchemist. Snap of the fingers, fire storm.",
    ),
    ThemedMilestone(
      name: "Scar",
      flavor: "Deconstruction arm. Shattering the state alchemists.",
    ),
    ThemedMilestone(
      name: "Greed/Ling",
      flavor: "The Ultimate Shield. Hardening carbon skin to block all hits.",
    ),
    ThemedMilestone(
      name: "King Bradley",
      flavor: "The Ultimate Eye. Slicing tank shells with a saber.",
    ),
    ThemedMilestone(
      name: "Hohenheim",
      flavor: "A living Philosopher's Stone. Ancient wisdom.",
    ),
    ThemedMilestone(
      name: "Father (God)",
      flavor: "Swallowing the sun. The ultimate alchemical god form.",
    ),
    ThemedMilestone(
      name: "Truth",
      flavor:
          "I am what you call the World, or perhaps the Universe, or God, or Truth.",
    ),
  ],
  "dbz": [
    ThemedMilestone(
      name: "Yamcha",
      flavor: "Wolf Fang Fist! Unfortunately lying in a crater.",
    ),
    ThemedMilestone(
      name: "Yajirobe",
      flavor: "Cutting the tail of Vegeta when he least expects it.",
    ),
    ThemedMilestone(
      name: "Master Roshi",
      flavor: "Kamehameha! The original master showing the path.",
    ),
    ThemedMilestone(
      name: "Krillin",
      flavor: "Destructo Disc! The best friend who always stands up.",
    ),
    ThemedMilestone(
      name: "Tien Shinhan",
      flavor: "Neo Tri-Beam! Holding back Cell with pure life energy.",
    ),
    ThemedMilestone(
      name: "Piccolo",
      flavor: "Special Beam Cannon! The wise teacher of the next generation.",
    ),
    ThemedMilestone(
      name: "Raditz",
      flavor: "Double Sunday. The first space invader defeated.",
    ),
    ThemedMilestone(
      name: "Nappa",
      flavor: "Giant Storm. Raw power clearing the field.",
    ),
    ThemedMilestone(
      name: "Vegeta (Saiyan)",
      flavor: "Galick Gun! The proud prince of all Saiyans.",
    ),
    ThemedMilestone(
      name: "Frieza (First)",
      flavor: "Supernova. Destroying planets with a finger.",
    ),
    ThemedMilestone(
      name: "Goku (SSJ)",
      flavor: "The legendary Super Saiyan. Awakened by pure anger.",
    ),
    ThemedMilestone(
      name: "Trunks (Future)",
      flavor: "Slicing Frieza into cubes with the sword of hope.",
    ),
    ThemedMilestone(
      name: "Android 18",
      flavor: "Breaking the arms of pride. Infinite energy generator.",
    ),
    ThemedMilestone(
      name: "Perfect Cell",
      flavor: "Solar Kamehameha. The perfect biological weapon.",
    ),
    ThemedMilestone(
      name: "Majin Buu",
      flavor: "Turning the cravings into chocolate. Regenerating from dust.",
    ),
    ThemedMilestone(
      name: "Gohan (SSJ2)",
      flavor: "Father-Son Kamehameha. Smashed the limits.",
    ),
    ThemedMilestone(
      name: "Vegito",
      flavor: "Yosha! The ultimate fusion of rivals.",
    ),
    ThemedMilestone(
      name: "Beerus",
      flavor: "Hakai. Destruction of the old universe of habits.",
    ),
    ThemedMilestone(
      name: "Whis",
      flavor: "Autonomous Ultra Instinct. Moving without thinking.",
    ),
    ThemedMilestone(
      name: "Grand Priest",
      flavor: "Commanding the angels. Power beyond comprehension.",
    ),
    ThemedMilestone(
      name: "Omni-King Zeno",
      flavor: "Squishing the entire universe of issues between two fingers.",
    ),
  ],
  "codegeass": [
    ThemedMilestone(
      name: "Shirley Fenette",
      flavor: "Swimming club. A heart full of love and tragic memory.",
    ),
    ThemedMilestone(
      name: "Milly Ashford",
      flavor: "Festival organizer. Creating fun events to distract.",
    ),
    ThemedMilestone(
      name: "Rivalz Cardemonde",
      flavor: "Riding the motorcycle, helping Zero behind the scenes.",
    ),
    ThemedMilestone(
      name: "Nina Einstein",
      flavor: "Frightened in the lab, constructing the FLEIJA nuke.",
    ),
    ThemedMilestone(
      name: "Villetta Nu",
      flavor: "A Knight of Honor. Memories lost and found.",
    ),
    ThemedMilestone(
      name: "Diethard Ried",
      flavor: "Recording the history of Zero. The media master.",
    ),
    ThemedMilestone(
      name: "Cecile Croomy",
      flavor: "Designing Lancelot. The scientific support.",
    ),
    ThemedMilestone(
      name: "Lloyd Asplund",
      flavor: "Pudding lover. Building the future of white armor.",
    ),
    ThemedMilestone(
      name: "Ohgi Kaname",
      flavor: "Leading the resistance. A simple man with a big heart.",
    ),
    ThemedMilestone(
      name: "Tamaki Shinichiro",
      flavor: "Zero's best friend. Loud but loyal to the cause.",
    ),
    ThemedMilestone(
      name: "Jeremiah (Orange)",
      flavor: "Orange is the color of my loyalty! Cyborg awaken.",
    ),
    ThemedMilestone(
      name: "Rolo Lamperouge",
      flavor: "Absolute defense. Stopping time for the brother.",
    ),
    ThemedMilestone(
      name: "Xingke Li",
      flavor: "The military genius. Slicing with the red sword.",
    ),
    ThemedMilestone(
      name: "Charles zi Britannia",
      flavor: "The Ragnarok Connection. Rewriting the past.",
    ),
    ThemedMilestone(
      name: "Schneizel",
      flavor: "The chess grandmaster. Playing the global war board.",
    ),
    ThemedMilestone(
      name: "Kallen (Guren)",
      flavor: "Radiation surge! Slicing through the holy empire.",
    ),
    ThemedMilestone(
      name: "Suzaku (Lancelot)",
      flavor: "Live command active! Spinning kicks of justice.",
    ),
    ThemedMilestone(
      name: "C.C.",
      flavor: "The witch of Geass. Granting the power of kings.",
    ),
    ThemedMilestone(
      name: "V.V.",
      flavor: "Code bearer. The eternal child of the collective unconscious.",
    ),
    ThemedMilestone(
      name: "Lelouch (Zero)",
      flavor: "If the king does not lead, his subjects will not follow.",
    ),
    ThemedMilestone(
      name: "Emperor Lelouch",
      flavor: "Lelouch vi Britannia commands you: OBEY ME!",
    ),
  ],
  "deathnote": [
    ThemedMilestone(
      name: "Matsuda",
      flavor: "Matsuda, you idiot! But still the hero in the final hour.",
    ),
    ThemedMilestone(
      name: "Kanzo Mogi",
      flavor: "Silent, working the details, highly reliable detective.",
    ),
    ThemedMilestone(
      name: "Aizawa",
      flavor: "Afro detective. Finding the clues in the task force.",
    ),
    ThemedMilestone(
      name: "Ukita",
      flavor: "First to charge the Sakura TV station. Brave heart.",
    ),
    ThemedMilestone(
      name: "Raye Penber",
      flavor: "Agent in the train. Falling into the trap of names.",
    ),
    ThemedMilestone(
      name: "Naomi Misora",
      flavor: "High-IQ detective. Tragically silenced before she spoke.",
    ),
    ThemedMilestone(
      name: "Mello",
      flavor: "Eating chocolate. Chasing Kira with the mafia.",
    ),
    ThemedMilestone(
      name: "Teru Mikami",
      flavor: "DELETE! Writing names in the notebook of delete.",
    ),
    ThemedMilestone(
      name: "Soichiro Yagami",
      flavor: "The honest father. Carrying the police shield to the end.",
    ),
    ThemedMilestone(
      name: "Kiyomi Takada",
      flavor: "The spokesperson of Kira. A beautiful news anchor.",
    ),
    ThemedMilestone(
      name: "Misa Amane",
      flavor: "Shinigami eyes. The second Kira devoted to the cause.",
    ),
    ThemedMilestone(
      name: "Wedy",
      flavor: "Cracking the safes, installing the cameras. Stealthed.",
    ),
    ThemedMilestone(
      name: "Aiber",
      flavor: "Con man. Putting on the fake face to extract information.",
    ),
    ThemedMilestone(
      name: "Watari",
      flavor: "Unbreakable butler. Supporting the world's greatest detective.",
    ),
    ThemedMilestone(
      name: "Near (N)",
      flavor: "Playing with toys. Solving the puzzle piece by piece.",
    ),
    ThemedMilestone(
      name: "L Lawliet",
      flavor: "Solving the case. The world's greatest mind.",
    ),
    ThemedMilestone(
      name: "Light Yagami (Kira)",
      flavor: "I will become the god of the new world.",
    ),
    ThemedMilestone(
      name: "Rem",
      flavor: "Sacrificing the shinigami life to save the loved one.",
    ),
    ThemedMilestone(
      name: "Ryuk",
      flavor: "Apples taste better when they are juicy. The spectator.",
    ),
    ThemedMilestone(
      name: "Gelus",
      flavor: "Writing the name to save Misa. Reduced to sand.",
    ),
    ThemedMilestone(
      name: "Shinigami King",
      flavor: "The absolute ruler of the death realm. Master of the books.",
    ),
  ],
  "gintama": [
    ThemedMilestone(
      name: "Shinpachi Shimura",
      flavor: "95% glasses, 5% human. The straight man of the trio.",
    ),
    ThemedMilestone(
      name: "Sagaru Yamazaki",
      flavor: "Playing badminton. Eating anpan for days on stakeouts.",
    ),
    ThemedMilestone(
      name: "Taizo Hasegawa",
      flavor: "MADAO! Totally useless, but has the heart of a samurai.",
    ),
    ThemedMilestone(
      name: "Otose",
      flavor: "The landlord who demands the rent with a cigarette in hand.",
    ),
    ThemedMilestone(
      name: "Catherine",
      flavor: "Cat-eared thief. Finding the path of reform at Otose's bar.",
    ),
    ThemedMilestone(
      name: "Tama",
      flavor: "Robot maid. Cleaning the dirt of the streets and the soul.",
    ),
    ThemedMilestone(
      name: "Sadaharu",
      flavor: "Giant white dog. Biting the head of Gintoki for love.",
    ),
    ThemedMilestone(
      name: "Kyubei Yagyu",
      flavor: "Raised as a male. Speed sword style of the Yagyu family.",
    ),
    ThemedMilestone(
      name: "Sarutobi Ayame",
      flavor: "Ninja assassin. Throwing natto to bind the triggers.",
    ),
    ThemedMilestone(
      name: "Tsukuyo",
      flavor:
          "The Courtesan of Death. Kunai throwing in the night of Yoshiwara.",
    ),
    ThemedMilestone(
      name: "Shinsuke Takasugi",
      flavor: "I simply destroy. Burning down the old world.",
    ),
    ThemedMilestone(
      name: "Kotaro Katsura",
      flavor: "It's not standby, it's Zura! Leading the patriots.",
    ),
    ThemedMilestone(
      name: "Isao Kondo",
      flavor: "Gorilla chief. Leading the Shinsengumi with naked honor.",
    ),
    ThemedMilestone(
      name: "Toshiro Hijikata",
      flavor: "Mayonnaise King. Demonic vice-commander of the force.",
    ),
    ThemedMilestone(
      name: "Sogo Okita",
      flavor: "Sadist captain. Firing the bazooka at Hijikata.",
    ),
    ThemedMilestone(
      name: "Abuto",
      flavor: "Yato warrior. Surviving the cold space of battle.",
    ),
    ThemedMilestone(
      name: "Kamui",
      flavor: "Yato Prince. Smiling while fighting the strongest.",
    ),
    ThemedMilestone(
      name: "Kagura",
      flavor: "Yato strength. Eating raw rice, punching through walls.",
    ),
    ThemedMilestone(
      name: "Gintoki (Shiroyasha)",
      flavor: "The white demon. Slicing with the wooden sword Bokuto.",
    ),
    ThemedMilestone(
      name: "Umibozu",
      flavor: "The alien hunter. The strongest father in the galaxy.",
    ),
    ThemedMilestone(
      name: "Utsuro",
      flavor: "The immortal spirit. The absolute enemy who has lived eternity.",
    ),
  ],
  "hxh": [
    ThemedMilestone(
      name: "Tonpa",
      flavor: "Rookie Crusher. Spicing the juice with poison, avoid him!",
    ),
    ThemedMilestone(
      name: "Pokkle",
      flavor: "Using the bow. Unfortunately met the chimera ants.",
    ),
    ThemedMilestone(
      name: "Leorio Paradinight",
      flavor: "Using the suitcase. Fighting for the medical degree.",
    ),
    ThemedMilestone(
      name: "Wing",
      flavor: "Untucking the shirt. Explaining the basics of Nen energy.",
    ),
    ThemedMilestone(
      name: "Hanzo",
      flavor: "Ninja speed. Training since childhood for the scroll.",
    ),
    ThemedMilestone(
      name: "Kurapika",
      flavor:
          "Emperor Time! Slicing the Phantom Troupe with chains of resolve.",
    ),
    ThemedMilestone(
      name: "Killua Zoldyck",
      flavor: "Godspeed! Electricity running through the nerves.",
    ),
    ThemedMilestone(
      name: "Gon Freecss",
      flavor: "Jajanken! Rock, paper, scissors of raw enhancer power.",
    ),
    ThemedMilestone(
      name: "Knuckle Bine",
      flavor: "Hakoware! Calculating the debt of energy.",
    ),
    ThemedMilestone(
      name: "Shoot McMahone",
      flavor: "Floating hands. Finding the courage in the dark.",
    ),
    ThemedMilestone(
      name: "Morel Mackernasey",
      flavor: "Deep Purple. Smoking the giant pipe of clouds.",
    ),
    ThemedMilestone(
      name: "Kastro",
      flavor: "Double technique. Creating the clone on the stage.",
    ),
    ThemedMilestone(
      name: "Feitan Portor",
      flavor: "Rising Sun! Burning the opponent with the heat of a star.",
    ),
    ThemedMilestone(
      name: "Hisoka Morow",
      flavor: "Bungee Gum has the properties of both rubber and gum!",
    ),
    ThemedMilestone(
      name: "Chrollo Lucilfer",
      flavor: "Skill Hunter. Stealing the techniques of the world.",
    ),
    ThemedMilestone(
      name: "Illumi Zoldyck",
      flavor: "Manipulating the face with needles. Cold assassin eyes.",
    ),
    ThemedMilestone(
      name: "Silva Zoldyck",
      flavor: "Crushing the ground with electric energy spheres.",
    ),
    ThemedMilestone(
      name: "Zeno Zoldyck",
      flavor: "Dragon Head! Raining dragon arrows from the sky.",
    ),
    ThemedMilestone(
      name: "Isaac Netero",
      flavor: "100-Type Guanyin Bodhisattva. 10000 punches of gratitude.",
    ),
    ThemedMilestone(
      name: "Meruem",
      flavor: "Apex chimera ant. The peak of biological evolution.",
    ),
    ThemedMilestone(
      name: "Adult Gon",
      flavor: "Awakened Gon. Sashing the limits of potential forever.",
    ),
  ],
  "sololeveling": [
    ThemedMilestone(
      name: "E-Rank Hunter",
      flavor:
          "The absolute bottom of the association. Scraping by with minor injuries.",
    ),
    ThemedMilestone(
      name: "D-Rank Hunter",
      flavor: "Slightly stronger, but still running from the dungeon bosses.",
    ),
    ThemedMilestone(
      name: "C-Rank Hunter",
      flavor: "The working class of the raids. Mining and carrying the bags.",
    ),
    ThemedMilestone(
      name: "B-Rank Hunter",
      flavor: "Reliable support and healers. Keeping the strike team alive.",
    ),
    ThemedMilestone(
      name: "A-Rank Hunter",
      flavor: "Local raid leaders. Respected professionals of elite guilds.",
    ),
    ThemedMilestone(
      name: "S-Rank Hunter",
      flavor:
          "A walking natural disaster. Power that defies conventional measurement.",
    ),
    ThemedMilestone(
      name: "Cha Hae-In",
      flavor:
          "The dancer of the battlefield. The top S-rank hunter of South Korea.",
    ),
    ThemedMilestone(
      name: "Thomas Andre",
      flavor:
          "The Goliath. A National Level Hunter with gravity-bending power.",
    ),
    ThemedMilestone(
      name: "Kargalgan",
      flavor: "The High Orc Shaman boss. Dictating the magic of the portal.",
    ),
    ThemedMilestone(
      name: "Demon King Baran",
      flavor: "Ruler of the Demon Castle. Firing blue lightning from the sky.",
    ),
    ThemedMilestone(
      name: "Ant King Beru",
      flavor:
          "The Jeju Island disaster. A predator who devours S-ranks to adapt.",
    ),
    ThemedMilestone(
      name: "Blood-Red Igris",
      flavor:
          "The loyal Knight Commander of the Shadow Army. Elegant swordplay.",
    ),
    ThemedMilestone(
      name: "Grand Marshal Bellion",
      flavor: "Commanding the shadow legions. The strongest shadow servant.",
    ),
    ThemedMilestone(
      name: "Beast Monarch",
      flavor: "The Monarch of Beastly Fangs. Ruthless predator of the wild.",
    ),
    ThemedMilestone(
      name: "Frost Monarch",
      flavor: "Master of the ice spears. Freezing the world in cold blocks.",
    ),
    ThemedMilestone(
      name: "Iron Body Monarch",
      flavor: "Unbreakable physical presence. The ultimate defense monarch.",
    ),
    ThemedMilestone(
      name: "Ashborn",
      flavor: "The original Shadow Monarch. Leader of the army of death.",
    ),
    ThemedMilestone(
      name: "Antares",
      flavor:
          "The Monarch of Destruction. Strongest villain, the ultimate red dragon.",
    ),
    ThemedMilestone(
      name: "The Rulers",
      flavor: "The bright fragments of brilliant light. Godly cosmic powers.",
    ),
    ThemedMilestone(
      name: "Absolute Creator",
      flavor:
          "The supreme entity who created the system of monarchs and rulers.",
    ),
    ThemedMilestone(
      name: "Shadow Monarch Jinwoo",
      flavor:
          "The ultimate Sung Jinwoo. Controlling death, rewriting time itself.",
    ),
  ],
  "rpg": [
    ThemedMilestone(
      name: "Wooden Shovel",
      flavor: "Digging the dirt of the past. Very slow progress.",
    ),
    ThemedMilestone(
      name: "Wooden Sword",
      flavor: "Defending yourself against the first night zombies.",
    ),
    ThemedMilestone(
      name: "Stone Pickaxe",
      flavor: "Mining the iron. Solid stone foundations.",
    ),
    ThemedMilestone(
      name: "Furnace Builder",
      flavor: "Smelting the raw resources. Generating heat.",
    ),
    ThemedMilestone(
      name: "Iron Ingot Maker",
      flavor: "Forging the first iron tool set. Shiny metal.",
    ),
    ThemedMilestone(
      name: "Iron Armor Set",
      flavor: "Fully protected against standard threats. Clang!",
    ),
    ThemedMilestone(
      name: "Gold Apple Eater",
      flavor: "Regeneration active! Healing from the damage.",
    ),
    ThemedMilestone(
      name: "Redstone Engineer",
      flavor: "Automating the daily habits with redstone circuits.",
    ),
    ThemedMilestone(
      name: "Diamond Miner",
      flavor: "Deep in the caves. The blue diamond shines in the dark.",
    ),
    ThemedMilestone(
      name: "Nether Portal",
      flavor: "Stepping into the nether dimension. Fire and lava.",
    ),
    ThemedMilestone(
      name: "Obsidian Harvester",
      flavor: "Mining the hardest blocks with diamond speed.",
    ),
    ThemedMilestone(
      name: "Blaze Powder",
      flavor: "Brewing the potions of speed and strength.",
    ),
    ThemedMilestone(
      name: "Ender Eye Crafter",
      flavor: "Locating the portal to the end of the game.",
    ),
    ThemedMilestone(
      name: "Stronghold Finder",
      flavor: "Finding the hidden dungeon beneath the world.",
    ),
    ThemedMilestone(
      name: "Netherite Smith",
      flavor: "Upgrading the diamond tools with netherite template.",
    ),
    ThemedMilestone(
      name: "Full Netherite",
      flavor: "Unbreakable, fireproof armor. The ultimate defense.",
    ),
    ThemedMilestone(
      name: "Elytra Flier",
      flavor: "Gliding through the sky. Soaring above the blocks.",
    ),
    ThemedMilestone(
      name: "Beacon Powerer",
      flavor: "Setting up the beacon of light. Haste and strength active.",
    ),
    ThemedMilestone(
      name: "Wither Defeater",
      flavor: "Defeating the three-headed wither boss in the deep caves.",
    ),
    ThemedMilestone(
      name: "Dragon Conqueror",
      flavor: "Defeating the Ender Dragon. The exit portal opens.",
    ),
    ThemedMilestone(
      name: "Creative Mode",
      flavor: "Fly, build, create. You have unlimited resources.",
    ),
  ],
  "tech": [
    ThemedMilestone(
      name: "HTML Editor",
      flavor: "Creating index.html. 'Hello World' on the screen.",
    ),
    ThemedMilestone(
      name: "CSS Styler",
      flavor: "Adding colors and borders. Center the div!",
    ),
    ThemedMilestone(
      name: "Script Kiddie",
      flavor: "Running random scripts from the internet. Hackermode.",
    ),
    ThemedMilestone(
      name: "Tutorial Hell",
      flavor: "Watching hours of courses without writing code. Stuck.",
    ),
    ThemedMilestone(
      name: "StackOverflow Copier",
      flavor: "Ctrl+C, Ctrl+V. If it works, don't touch it.",
    ),
    ThemedMilestone(
      name: "Junior Developer",
      flavor: "The first job! Fixing typos in production. Frightened.",
    ),
    ThemedMilestone(
      name: "Code Refactorer",
      flavor: "Cleaning up the messy codebase of the past. Modular.",
    ),
    ThemedMilestone(
      name: "Git Resolver",
      flavor: "Resolving merge conflicts without deleting main. Master.",
    ),
    ThemedMilestone(
      name: "Senior Engineer",
      flavor: "Writing scalable, clean code. Refusing useless meetings.",
    ),
    ThemedMilestone(
      name: "Tech Lead",
      flavor: "Guiding the team, reviewing PRs, managing the stack.",
    ),
    ThemedMilestone(
      name: "Principal Architect",
      flavor: "Drawing system diagrams on whiteboards. Big picture.",
    ),
    ThemedMilestone(
      name: "CTO",
      flavor: "Leading the technology vision of the entire company.",
    ),
    ThemedMilestone(
      name: "Open Source Contributor",
      flavor: "Fixing issues in the libraries the world relies on.",
    ),
    ThemedMilestone(
      name: "Database Admin",
      flavor: "Optimizing indexes. SELECT * FROM sobriety;",
    ),
    ThemedMilestone(
      name: "SRE Guru",
      flavor: "Keeping the servers running during peak traffic. Zero downtime.",
    ),
    ThemedMilestone(
      name: "Cloud Architect",
      flavor: "Deploying global kubernetes clusters. Infinite scaling.",
    ),
    ThemedMilestone(
      name: "Compiler Architect",
      flavor: "Writing your own language compiler. High performance.",
    ),
    ThemedMilestone(
      name: "Linux Kernel Dev",
      flavor: "Submitting patches to the kernel code. C-level mastery.",
    ),
    ThemedMilestone(
      name: "Linus Torvalds",
      flavor: "Ranting on mailing lists. Creating Git and Linux.",
    ),
    ThemedMilestone(
      name: "AI Overlord",
      flavor: "Constructing the artificial intelligence system of the future.",
    ),
    ThemedMilestone(
      name: "Turing Award",
      flavor: "Recognized for lifetime contributions to computer science.",
    ),
  ],
  "chess": [
    ThemedMilestone(
      name: "Scholar's Mate Victim",
      flavor: "Losing in four moves. Learning to protect f7.",
    ),
    ThemedMilestone(
      name: "Blundering Beginner",
      flavor: "Hanging the queen. Learning to scan the board.",
    ),
    ThemedMilestone(
      name: "800 Elo Novice",
      flavor: "Starting to win matches. Finding simple forks.",
    ),
    ThemedMilestone(
      name: "1200 Elo Club",
      flavor: "Solving chess puzzles. Knowing basic openings.",
    ),
    ThemedMilestone(
      name: "Casual Club Player",
      flavor: "Playing in local tournaments. Good tactical vision.",
    ),
    ThemedMilestone(
      name: "Tournament Novice",
      flavor: "Using the chess clock. Writing down the moves.",
    ),
    ThemedMilestone(
      name: "1500 Elo Intermediate",
      flavor: "Understanding pawn structures and minor piece value.",
    ),
    ThemedMilestone(
      name: "Club Champion",
      flavor: "Dominating the local scene. Solid positional play.",
    ),
    ThemedMilestone(
      name: "Candidate Master",
      flavor: "FIDE rated. Entering the international master path.",
    ),
    ThemedMilestone(
      name: "FIDE Master",
      flavor: "FM title earned. Strategic depth in endgames.",
    ),
    ThemedMilestone(
      name: "International Master",
      flavor: "Three norms achieved. IM title confirmed. Elite.",
    ),
    ThemedMilestone(
      name: "Grandmaster",
      flavor: "The ultimate title. GM norms secured. Total mastery.",
    ),
    ThemedMilestone(
      name: "Super GM (2700+)",
      flavor: "Belonging to the top 50 players in the world. Legend.",
    ),
    ThemedMilestone(
      name: "Candidates Contender",
      flavor: "Fighting for the right to challenge the champion.",
    ),
    ThemedMilestone(
      name: "Championship Challenger",
      flavor: "Standing on the grand stage of the world match.",
    ),
    ThemedMilestone(
      name: "World Champion",
      flavor: "Crowned king of the chess world. Inscribed in history.",
    ),
    ThemedMilestone(
      name: "Deep Blue",
      flavor: "Defeating Garry Kasparov in a match. Silicon dawn.",
    ),
    ThemedMilestone(
      name: "AlphaZero",
      flavor: "Learning by playing itself. A beautiful, romantic style.",
    ),
    ThemedMilestone(
      name: "Stockfish 17",
      flavor: "Absolute engine calculation. 3600+ Elo power.",
    ),
    ThemedMilestone(
      name: "Garry Kasparov",
      flavor: "The beast of Baku. Dominating the chess world for 20 years.",
    ),
    ThemedMilestone(
      name: "Magnus Carlsen",
      flavor: "The endgame wizard. Highest rating in history: 2882.",
    ),
  ],
  "starwars": [
    ThemedMilestone(
      name: "Moisture Farmer",
      flavor: "Looking at the twin suns of Tatooine, dreaming of flight.",
    ),
    ThemedMilestone(
      name: "Youngling",
      flavor: "Learning to deflect training lasers with the lightsaber.",
    ),
    ThemedMilestone(
      name: "Padawan",
      flavor: "Braided hair. Accompanying the master on missions.",
    ),
    ThemedMilestone(
      name: "Jedi Initiate",
      flavor: "Studying the Jedi code at the temple archives.",
    ),
    ThemedMilestone(
      name: "Jedi Guardian",
      flavor: "Focusing on lightsaber combat. Blue blade igniting.",
    ),
    ThemedMilestone(
      name: "Clone Captain",
      flavor: "Leading the squad on the front lines. Commander Rex.",
    ),
    ThemedMilestone(
      name: "Jedi Knight",
      flavor: "Formally knighted. The trials passed. Guardian of peace.",
    ),
    ThemedMilestone(
      name: "Inquisitor",
      flavor: "Spinning red lightsaber. Hunting down the ghosts.",
    ),
    ThemedMilestone(
      name: "Jedi Sentinel",
      flavor: "Blending security with tracking. Yellow blade.",
    ),
    ThemedMilestone(
      name: "Jedi Consular",
      flavor: "Focusing on force philosophy and negotiation. Green blade.",
    ),
    ThemedMilestone(
      name: "Sith Apprentice",
      flavor: "Darth title earned. Embracing the passion and power.",
    ),
    ThemedMilestone(
      name: "Jedi Master",
      flavor: "Training a padawan to knighthood. Wise, composed.",
    ),
    ThemedMilestone(
      name: "Sith Lord",
      flavor: "Commanding the shadow empire. Red lightning.",
    ),
    ThemedMilestone(
      name: "Council Member",
      flavor: "Sitting in the Jedi high chamber. Master Windu.",
    ),
    ThemedMilestone(
      name: "General of the Army",
      flavor: "Commanding fleets of starfighters. High strategist.",
    ),
    ThemedMilestone(
      name: "Grand Master Yoda",
      flavor: "Size matters not. Moving starships with the finger.",
    ),
    ThemedMilestone(
      name: "Darth Vader",
      flavor: "The Imperial March. Absolute terror of the galaxy.",
    ),
    ThemedMilestone(
      name: "Luke Skywalker",
      flavor: "Rebuilding the Jedi order. Unshakable light side.",
    ),
    ThemedMilestone(
      name: "Emperor Palpatine",
      flavor: "Unlimited power! Master of the dark side plans.",
    ),
    ThemedMilestone(
      name: "Force Ghost",
      flavor: "One with the Force. Guiding the future generations.",
    ),
    ThemedMilestone(
      name: "The Chosen One",
      flavor: "Anakin Skywalker. Balancing the force forever.",
    ),
  ],
  "potter": [
    ThemedMilestone(
      name: "Muggle",
      flavor: "No magic, living in the normal world. Blind to the wonder.",
    ),
    ThemedMilestone(
      name: "Squib",
      flavor: "Born in a wizard family but no magic. Cleaning the castle.",
    ),
    ThemedMilestone(
      name: "Letter Recipient",
      flavor: "The owl delivers the green-ink envelope. The door opens.",
    ),
    ThemedMilestone(
      name: "Diagon Alley Visitor",
      flavor: "Buying the wand at Ollivanders. The wand chooses you.",
    ),
    ThemedMilestone(
      name: "First Year Student",
      flavor: "Crossing the lake in boats. The castle windows shine.",
    ),
    ThemedMilestone(
      name: "Sorted House Member",
      flavor:
          "The sorting hat decides: Gryffindor, Slytherin, Ravenclaw, Hufflepuff.",
    ),
    ThemedMilestone(
      name: "Quidditch Seeker",
      flavor: "Catching the golden snitch! 150 points to the team.",
    ),
    ThemedMilestone(
      name: "Prefect",
      flavor: "Shiny badge. Keeping the house corridors safe in the night.",
    ),
    ThemedMilestone(
      name: "D.A. Member",
      flavor: "Dumbledore's Army. Practicing defense spells in secret.",
    ),
    ThemedMilestone(
      name: "OWLs Passer",
      flavor: "Outstanding in Defense Against the Dark Arts. Exams done.",
    ),
    ThemedMilestone(
      name: "Head Boy/Girl",
      flavor: "Leading the entire student body. Trusted by the headmaster.",
    ),
    ThemedMilestone(
      name: "Ministry Employee",
      flavor: "Working in the Department of Magical Transportation. Office.",
    ),
    ThemedMilestone(
      name: "Hogwarts Professor",
      flavor: "Teaching the next generation how to brew potions.",
    ),
    ThemedMilestone(
      name: "Order Member",
      flavor: "Fighting the dark forces in the secret resistance.",
    ),
    ThemedMilestone(
      name: "Death Eater",
      flavor: "The dark mark on the arm. Cold, dark ambition.",
    ),
    ThemedMilestone(
      name: "Auror",
      flavor: "Elite dark wizard catcher. Tracking down the danger.",
    ),
    ThemedMilestone(
      name: "Minister for Magic",
      flavor: "Leading the wizarding government. Ruling the community.",
    ),
    ThemedMilestone(
      name: "Lord Voldemort",
      flavor: "He-Who-Must-Not-Be-Named. Slicing the soul into Horcruxes.",
    ),
    ThemedMilestone(
      name: "Gellert Grindelwald",
      flavor: "For the greater good. The deathly hallows master.",
    ),
    ThemedMilestone(
      name: "Albus Dumbledore",
      flavor: "The elder wand master. Fawkes on the shoulder. Wise, powerful.",
    ),
    ThemedMilestone(
      name: "Merlin",
      flavor: "The greatest wizard of all time. Order of Merlin, First Class.",
    ),
  ],
  "marvel": [
    ThemedMilestone(
      name: "Civilian",
      flavor: "Just a citizen of New York. Looking up at the sky.",
    ),
    ThemedMilestone(
      name: "Bugle Reporter",
      flavor: "Taking pictures of Spider-Man. Parker, get me photos!",
    ),
    ThemedMilestone(
      name: "S.H.I.E.L.D. Agent",
      flavor: "Running the helicarrier database. Eye patch ready.",
    ),
    ThemedMilestone(
      name: "Hawkeye",
      flavor: "Never missing the target with the bow. Precision focus.",
    ),
    ThemedMilestone(
      name: "Black Widow",
      flavor: "Spy craft and stingers. Infiltrating the target room.",
    ),
    ThemedMilestone(
      name: "Falcon",
      flavor: "Mechanical wings. Flying through the anti-aircraft fire.",
    ),
    ThemedMilestone(
      name: "Winter Soldier",
      flavor: "Metal arm. Cold, precise assassin reprogrammed.",
    ),
    ThemedMilestone(
      name: "Captain America",
      flavor: "I can do this all day. Unbreakable vibranium shield.",
    ),
    ThemedMilestone(
      name: "Iron Man",
      flavor: "Nanotech armor. Firing repulsors. I am Iron Man.",
    ),
    ThemedMilestone(
      name: "Spider-Man",
      flavor: "With great power comes great responsibility. Web-slinging.",
    ),
    ThemedMilestone(
      name: "Black Panther",
      flavor: "King of Wakanda. Vibranium claws, absolute majesty.",
    ),
    ThemedMilestone(
      name: "Doctor Strange",
      flavor: "Master of Mystic Arts. Drawing orange shields in the air.",
    ),
    ThemedMilestone(
      name: "Scarlet Witch",
      flavor: "Chaos magic. Reality warping at your fingertips.",
    ),
    ThemedMilestone(
      name: "Thor Odinson",
      flavor: "God of Thunder. Summoning lightning with Stormbreaker.",
    ),
    ThemedMilestone(
      name: "Hulk (World Breaker)",
      flavor: "Smashing the entire landscape. Unbridled anger channelled.",
    ),
    ThemedMilestone(
      name: "Odin (All-Father)",
      flavor: "Gungnir spear. Guarding Asgard with ancient force.",
    ),
    ThemedMilestone(
      name: "Galactus",
      flavor: "Devourer of Worlds. A massive cosmic presence of hunger.",
    ),
    ThemedMilestone(
      name: "Thanos (Gauntlet)",
      flavor: "The snap of fingers. Six infinity stones shining.",
    ),
    ThemedMilestone(
      name: "Eternity",
      flavor:
          "The cosmic embodiment of the universe itself. Infinite star map.",
    ),
    ThemedMilestone(
      name: "Living Tribunal",
      flavor: "Three-faced cosmic judge. Balancing the multiverse.",
    ),
    ThemedMilestone(
      name: "The One Above All",
      flavor:
          "The absolute creator of everything. The pencil that draws reality.",
    ),
  ],
};

// Helper methods for lookups
int getMilestoneIndex(SobrietyMilestoneEntry entry) {
  return kSobrietyMilestones.indexOf(entry);
}

String getMilestoneName(SobrietyMilestoneEntry entry, String themeId) {
  final idx = getMilestoneIndex(entry);
  if (idx == -1) return entry.dayLabel;
  final list = kThemeMilestones[themeId] ?? kThemeMilestones['science']!;
  if (idx >= list.length) return entry.dayLabel;
  return list[idx].name;
}

String getMilestoneFlavor(SobrietyMilestoneEntry entry, String themeId) {
  final idx = getMilestoneIndex(entry);
  if (idx == -1) return '';
  final list = kThemeMilestones[themeId] ?? kThemeMilestones['science']!;
  if (idx >= list.length) return '';
  return list[idx].flavor;
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
