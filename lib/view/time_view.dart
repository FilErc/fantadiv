import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/time_viewmodel.dart';

class TimeView extends StatelessWidget {
  final TimeViewModel viewModel;

  const TimeView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Modifica Timestamp Round"),
        ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text("Round Giorno ${round.day}"),
                    subtitle: Text("Data attuale: $timestampStr"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: round.timestamp ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (selectedDate == null) return;

                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            round.timestamp ?? DateTime.now(),
                          ),
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
    );
  }
}
