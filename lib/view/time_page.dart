import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/time_viewmodel.dart';

class TimeView extends StatelessWidget {
  final TimeViewModel viewModel;

  const TimeView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localDarkAmberTheme = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Colors.amber,
        secondary: Colors.amberAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey,
      iconTheme: const IconThemeData(color: Colors.amber),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.grey,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );

    return Theme(
      data: localDarkAmberTheme,
      child: ChangeNotifierProvider.value(
        value: viewModel,
        child: Scaffold(
          body: Consumer<TimeViewModel>(
            builder: (context, model, _) {
              if (model.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: model.rounds.length,
                itemBuilder: (context, index) {
                  final round = model.rounds[index];
                  final timestampStr = round.timestamp != null
                      ? round.timestamp.toString()
                      : "Nessuna data";

                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        "Round Giorno ${round.day}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Data attuale: $timestampStr",
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: round.timestamp ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: localDarkAmberTheme,
                                child: child!,
                              );
                            },
                          );

                          if (selectedDate == null) return;

                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              round.timestamp ?? DateTime.now(),
                            ),
                            builder: (context, child) {
                              return Theme(
                                data: localDarkAmberTheme,
                                child: child!,
                              );
                            },
                          );

                          if (selectedTime == null) return;

                          final combinedDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          await model.updateTimestamp(index, combinedDateTime);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Timestamp aggiornato")),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
