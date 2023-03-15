// import 'package:flutter/material.dart';
// import 'package:letshang/blocs/create_event/create_event_bloc.dart';
// import 'package:letshang/blocs/hang_event_participants/hang_event_participants_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:letshang/models/hang_event_model.dart';
// import 'package:letshang/models/user_invite_model.dart';
// import 'package:letshang/widgets/cards/user_event_card.dart';
// import 'package:letshang/widgets/hang_event_participants/add_group_bottom_modal.dart';
// import 'package:letshang/widgets/hang_event_participants/add_people_bottom_modal.dart';
// import 'package:letshang/widgets/lh_text_form_field.dart';

// class CreateEventScreen extends StatelessWidget {
//   const CreateEventScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xFFCCCCCC),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Color(0xFF9BADBD),
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text('Create Event'),
//         titleTextStyle: Theme.of(context).textTheme.headline4,
//       ),
//       backgroundColor: const Color(0xFFCCCCCC),
//       body: BlocProvider(
//           create: (context) => CreateEventBloc(), child: _CreateEventView()),
//     );
//   }
// }

// class _CreateEventView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Padding(
//             padding: const EdgeInsets.only(
//                 left: 20.0, right: 20.0, bottom: 20.0, top: 20.0),
//             child: Column(
//               children: [
//                 LHTextFormField(
//                   labelText: 'Event Name',
//                   backgroundColor: Colors.white,
//                   onChanged: (value) => context
//                       .read<CreateEventBloc>()
//                       .add(EventNameChanged(eventName: value)),
//                 ),
//                 Container(
//                   margin: const EdgeInsets.only(top: 20),
//                   child: const LHTextFormField(
//                       labelText: 'Location', backgroundColor: Colors.white),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 20),
//                   child: Row(children: [
//                     Flexible(
//                         flex: 1,
//                         child: InkWell(
//                             onTap: () {
//                               print("erere");
//                             },
//                             child: LHTextFormField(
//                               labelText: 'Date',
//                               backgroundColor: Colors.white,
//                               enabled: false,
//                               readOnly: true,
//                             ))),
//                     Flexible(
//                         flex: 1,
//                         child: InkWell(
//                             onTap: () {
//                               print("erere");
//                             },
//                             child: LHTextFormField(
//                               labelText: 'Time',
//                               backgroundColor: Colors.white,
//                               enabled: false,
//                               readOnly: true,
//                             )))
//                   ]),
//                 )

//                 // The validator receives the text that the user has entered.
//                 // TextFormField(
//                 //   autovalidateMode: AutovalidateMode.onUserInteraction,
//                 //   decoration: InputDecoration(labelText: 'Location'),
//                 //   initialValue: "",
//                 //   // The validator receives the text that the user has entered.
//                 // ),
//                 // Row(
//                 //   children: [
//                 //     TextFormField(
//                 //       autovalidateMode: AutovalidateMode.onUserInteraction,
//                 //       decoration: InputDecoration(labelText: 'Date'),
//                 //       initialValue: "",
//                 //       // The validator receives the text that the user has entered.
//                 //     ),
//                 //     TextFormField(
//                 //       autovalidateMode: AutovalidateMode.onUserInteraction,
//                 //       decoration: InputDecoration(labelText: 'Time'),
//                 //       initialValue: "",
//                 //       // The validator receives the text that the user has entered.
//                 //     )
//                 //   ],
//                 // )
//               ],
//             )));
//   }

//   Future<void> _selectStartDate(BuildContext context) async {
//     DateTime todaysDate = DateTime.now();
//     final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: selectedStartDate,
//         firstDate: todaysDate,
//         lastDate: DateTime(2101));
//     if (picked != null && picked != selectedStartDate) {
//       // once a different date is picked, reset the start time.
//       setState(() {
//         selectedStartDate = picked;
//         selectedStartTime = constants.startOfDay;
//         context.read<EditHangEventsBloc>().add(EventStartDateTimeChanged(
//             eventStartDate: selectedStartDate,
//             eventStartTime: selectedStartTime));
//         if (selectedStartDate.isAfter(selectedEndDate)) {
//           // if the start date is after the end date, then we need to adjust the end date to be the start date
//           selectedEndDate = selectedStartDate;
//           selectedEndTime = constants.startOfDay;
//           context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
//               eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));
//         }
//       });
//     }
//   }

//   List<Widget> _startDateTimeFields() {
//     return [
//       Text(DateFormat('MM/dd/yyyy').format(selectedStartDate)),
//       BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
//         builder: (context, state) {
//           return IconButton(
//             icon: const Icon(Icons.calendar_today_rounded),
//             highlightColor: Colors.pink,
//             onPressed: () => _selectStartDate(context),
//           );
//         },
//       ),
//       Text(_changeTimeToString(selectedStartTime)),
//       BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
//         builder: (context, state) {
//           return IconButton(
//             icon: const Icon(Icons.access_time),
//             highlightColor: Colors.pink,
//             onPressed: () => _selectStartTime(context),
//           );
//         },
//       ),
//     ];
//   }
// }
