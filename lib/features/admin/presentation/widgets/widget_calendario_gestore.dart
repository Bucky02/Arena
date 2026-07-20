import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:app_campi/core/theme/app_theme.dart';

class WidgetCalendarioGestore extends StatelessWidget {
  final CalendarController controller;
  final bool isLoading;
  final List<Appointment> prenotazioniVisibili;
  final double startHour;
  final double endHour;
  final Function(CalendarTapDetails) onTap;
  final Function(ViewChangedDetails) onViewChanged;
  final ScrollController? mainScrollController;

  const WidgetCalendarioGestore({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.prenotazioniVisibili,
    required this.startHour,
    required this.endHour,
    required this.onTap,
    required this.onViewChanged,
    this.mainScrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.neonOrange),
      );
    }

    final double oreVisibili = endHour - startHour;
    final double altezzaCalendario = oreVisibili * 60;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border.all(color: Colors.grey.shade900, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: SizedBox(
          height: altezzaCalendario + 40,
          child: Listener(
            onPointerMove: (pointerMoveEvent) {
              if (mainScrollController != null &&
                  mainScrollController!.hasClients) {
                mainScrollController!.position.jumpTo(
                  (mainScrollController!.offset - pointerMoveEvent.delta.dy)
                      .clamp(
                        0.0,
                        mainScrollController!.position.maxScrollExtent,
                      ),
                );
              }
            },
            child: SfCalendar(
              controller: controller,
              view: CalendarView.day,
              headerHeight: 0,
              firstDayOfWeek: 1,
              backgroundColor: AppTheme.cardBg,
              viewNavigationMode: ViewNavigationMode.none,
              maxDate: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                23,
                59,
                59,
              ).add(const Duration(days: 7)),
              dataSource: _PartiteDataSource(prenotazioniVisibili),
              onTap: onTap,
              viewHeaderStyle: const ViewHeaderStyle(
                dayTextStyle: TextStyle(color: Colors.white, fontSize: 12),
                dateTextStyle: TextStyle(color: Colors.white, fontSize: 12),
              ),
              timeSlotViewSettings: TimeSlotViewSettings(
                timeFormat: 'HH:mm',
                timeTextStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
                startHour: startHour,
                endHour: endHour,
                timeIntervalHeight: 60,
              ),
              onViewChanged: onViewChanged,
            ),
          ),
        ),
      ),
    );
  }
}

class _PartiteDataSource extends CalendarDataSource {
  _PartiteDataSource(List<Appointment> source) {
    appointments = source;
  }
}
