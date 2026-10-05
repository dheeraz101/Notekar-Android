import os

path = "lib/screens/executive_intelligence_hub_screen.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports
if "daily_wisdom_service.dart" not in content:
    content = content.replace("import 'package:notekar/utils/dashboard_metrics_service.dart';",
                              "import 'package:notekar/utils/dashboard_metrics_service.dart';\nimport 'package:notekar/utils/daily_wisdom_service.dart';\nimport 'package:notekar/utils/risk_radar_service.dart';")

# Replace build method to use FutureBuilder
old_build = """  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final now = DateTime.now();
    final todayKey = dateKey(now);
    final todayMoments = _moments.where((m) => m.date == todayKey).toList();
    final todaySections = buildTimelineDaySections(todayMoments);
    final todayTrackedDuration = todaySections.isNotEmpty
        ? todaySections.first.totalTrackedDuration
        : Duration.zero;

    final dashboardData = DashboardMetricsService.calculate(
      entries: _moments,
      timeframe: _selectedTimeframe,
      p: p,
    );

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context, p),

            // Timeframe Segmented Control
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildTimeframeControl(p),
            ),

            // Scrollable Dashboard Content
            Expanded(
              child: _isLoading
                  ? Center(child: CupertinoActivityIndicator(color: p.accent))
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 8.0,
                              bottom: 40.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. Hero Activity Ring & Pace
                                HeroActivityRingCard(p: p, data: dashboardData),
                                const SizedBox(height: 12),

                                // 2. Digital Wellbeing & Reality Ratio (Screen Time vs. Conscious Focus)
                                DigitalWellbeingCard(
                                  p: p,
                                  todayTrackedDuration: todayTrackedDuration,
                                  todayMomentsCount: todayMoments.length,
                                ),
                                const SizedBox(height: 12),

                                // 3. Intelligent Time Slot Bias
                                IntelligentTimeSlotBiasCard(
                                  p: p,
                                  data: dashboardData.timeSlotBias,
                                ),
                                const SizedBox(height: 12),

                                // 3. 7-Day Rhythm
                                DailyRhythmBarChart(
                                  p: p,
                                  data: dashboardData.dailyRhythm,
                                ),
                                const SizedBox(height: 12),

                                // 4. Focus Category Breakdown
                                FocusCategoryBreakdownCard(
                                  p: p,
                                  data: dashboardData.focusBreakdown,
                                ),
                                const SizedBox(height: 12),

                                // 5. 90-Day Activity Grid
                                ActivityGridCard(
                                  p: p,
                                  data: dashboardData.gridStats,
                                ),
                                const SizedBox(height: 12),

                                // 6. Memento Mori Life Horizon
                                MementoMoriCard(p: p),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }"""

new_build = """  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final now = DateTime.now();
    final todayKey = dateKey(now);
    final todayMoments = _moments.where((m) => m.date == todayKey).toList();
    final todaySections = buildTimelineDaySections(todayMoments);
    final todayTrackedDuration = todaySections.isNotEmpty
        ? todaySections.first.totalTrackedDuration
        : Duration.zero;

    final metricsFuture = DashboardMetricsService.calculateAsync(
      entries: _moments,
      timeframe: _selectedTimeframe,
      p: p,
    );
    final riskFuture = RiskRadarService.analyzeAsync(_moments);
    final wisdom = DailyWisdomService.getWisdom(now);

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context, p),

            // Timeframe Segmented Control
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildTimeframeControl(p),
            ),

            // Scrollable Dashboard Content
            Expanded(
              child: _isLoading
                  ? Center(child: CupertinoActivityIndicator(color: p.accent))
                  : FutureBuilder(
                      future: Future.wait([metricsFuture, riskFuture]),
                      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CupertinoActivityIndicator(color: p.accent));
                        }
                        
                        final dashboardData = snapshot.data![0] as ExecutiveDashboardData;
                        final riskData = snapshot.data![1] as RiskRadarResult;
                        
                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 8.0,
                                  bottom: 40.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Daily Wisdom
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: p.surface2,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: p.border.withOpacity(0.5)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.psychology_rounded, color: p.accent, size: 16),
                                              const SizedBox(width: 8),
                                              Text(
                                                'NEUROSCIENCE WISDOM',
                                                style: TextStyle(
                                                  color: p.accent,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '"${wisdom.quote}"',
                                            style: TextStyle(
                                              color: p.text,
                                              fontSize: 15,
                                              height: 1.4,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '— ${wisdom.author}',
                                            style: TextStyle(
                                              color: p.text2,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  
                                    // Risk Radar
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: riskData.riskLevel == 'High' ? p.red.withOpacity(0.1) : (riskData.riskLevel == 'Moderate' ? p.orange.withOpacity(0.1) : p.surface2),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: riskData.riskLevel == 'High' ? p.red.withOpacity(0.3) : p.border.withOpacity(0.5)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.radar_rounded, color: riskData.riskLevel == 'High' ? p.red : p.accent, size: 16),
                                              const SizedBox(width: 8),
                                              Text(
                                                'RISK RADAR',
                                                style: TextStyle(
                                                  color: riskData.riskLevel == 'High' ? p.red : p.accent,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: riskData.riskLevel == 'High' ? p.red : p.surface3,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${riskData.riskScore}% RISK',
                                                  style: TextStyle(
                                                    color: riskData.riskLevel == 'High' ? Colors.white : p.text,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            riskData.alertMessage,
                                            style: TextStyle(
                                              color: p.text,
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // 1. Hero Activity Ring & Pace
                                    HeroActivityRingCard(p: p, data: dashboardData),
                                    const SizedBox(height: 12),

                                    // 2. Digital Wellbeing & Reality Ratio (Screen Time vs. Conscious Focus)
                                    DigitalWellbeingCard(
                                      p: p,
                                      todayTrackedDuration: todayTrackedDuration,
                                      todayMomentsCount: todayMoments.length,
                                    ),
                                    const SizedBox(height: 12),

                                    // 3. Intelligent Time Slot Bias
                                    IntelligentTimeSlotBiasCard(
                                      p: p,
                                      data: dashboardData.timeSlotBias,
                                    ),
                                    const SizedBox(height: 12),

                                    // 3. 7-Day Rhythm
                                    DailyRhythmBarChart(
                                      p: p,
                                      data: dashboardData.dailyRhythm,
                                    ),
                                    const SizedBox(height: 12),

                                    // 4. Focus Category Breakdown
                                    FocusCategoryBreakdownCard(
                                      p: p,
                                      data: dashboardData.focusBreakdown,
                                    ),
                                    const SizedBox(height: 12),

                                    // 5. 90-Day Activity Grid
                                    ActivityGridCard(
                                      p: p,
                                      data: dashboardData.gridStats,
                                    ),
                                    const SizedBox(height: 12),

                                    // 6. Memento Mori Life Horizon
                                    MementoMoriCard(p: p),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
            ),
          ],
        ),
      ),
    );
  }"""

# Python replace works best if we ignore formatting. Let's use substring replacement.
# But it might be safer to replace using string bounds.

start_idx = content.find("  @override\n  Widget build(BuildContext context) {")
end_idx = content.find("  Widget _buildAppBar(BuildContext context, Palette p) {")

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + new_build + "\n\n" + content[end_idx:]

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Hub refactored")
