import 'package:flutter/material.dart';

// Sample model for a report.
class Report {
  final String description;
  final int supports;
  final bool cleared;

  Report({
    required this.description,
    required this.supports,
    required this.cleared,
  });
}

class ReportsPage extends StatelessWidget {
  ReportsPage({Key? key}) : super(key: key);

  // Sample list of reports.
  final List<Report> reports = [
    Report(
      description: 'The public has started using it as a bin',
      supports: 42,
      cleared: false,
    ),
    Report(
      description: 'The smell is really making us to throw up',
      supports: 55,
      cleared: true,
    ),
    Report(
      description: 'Illegal dumping near river',
      supports: 30,
      cleared: false,
    ),
    Report(
      description: 'More plastics than ever',
      supports: 68,
      cleared: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use SafeArea to push content below status bar.
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sticky header with title "Reports" and a light black line below.
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverHeaderDelegate(
                minHeight: 60,
                maxHeight: 60,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title text.
                      const Text(
                        'Reports',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Light black line.
                      Container(
                        height: 1,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // List of report cards.
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // Reverse order: newer reports at the top.
                  final report = reports[reports.length - 1 - index];
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ReportCard(report: report),
                  );
                },
                childCount: reports.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for each report card.
class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The card height is set to roughly 80, giving about 2.5-3 lines.
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Light gray background.
        borderRadius: BorderRadius.circular(12), // Curved edges.
      ),
      child: Row(
        children: [
          // Left section: occupies 3/10 of available width.
          Flexible(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          // Right section: occupies 7/10 of available width.
          Flexible(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description (one line, ellipsis if too long).
                  Text(
                    report.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Row with supports count and cleared status inside a rounded rectangle.
                  Row(
                    children: [
                      Text(
                        '${report.supports} supports',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: report.cleared
                              ? Colors.green.shade700
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report.cleared ? 'cleared' : 'not cleared',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom delegate for the sticky header.
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}