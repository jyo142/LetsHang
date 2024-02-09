// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:letshang/blocs/create_event/create_event_bloc.dart';
// import 'package:letshang/blocs/create_event/create_event_event.dart';
// import 'package:letshang/blocs/create_event/create_event_state.dart';
// import 'package:letshang/widgets/lh_button.dart';
// import 'package:letshang/widgets/lh_text_form_field.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class CreateEventLayout extends StatelessWidget {
//   final String createEventStep
//   const CreateEventLayout({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: const Color(0xFFECEEF4),
//           centerTitle: true,
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back,
//               color: Color(0xFF9BADBD),
//             ),
//             onPressed: () {
//               context.pop();
//             },
//           ),
//           title: const Text('Create Event'),
//           titleTextStyle: Theme.of(context).textTheme.headline4,
//         ),
//         body: _CreateEventLayoutView());
//   }
// }

// class _CreateEventLayoutView extends StatelessWidget {
//   _CreateEventLayoutView({Key? key}) : super(key: key);
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(child: BlocBuilder<CreateEventBloc, CreateEventState>(
//         builder: (context, state) {
//       return Column(
//         children: [
//           SizedBox(
//               height: 100,
//               child: const Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [Text("EEE")],
//               )),
//           Expanded(
//               child: Container(
//             decoration: const BoxDecoration(
//                 color: Color(0xFFFFFFFF),
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.elliptical(300, 50),
//                     topRight: Radius.elliptical(300, 50))),
//             child: Padding(
//                 padding: const EdgeInsets.only(
//                     left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       Flexible(
//                           flex: 8,
//                           child: Column(
//                             children: [
//                               const SizedBox(
//                                 height: 20,
//                               ),
//                               Text(
//                                 "Please give a short name and description for the event",
//                                 style: Theme.of(context).textTheme.headline4,
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(
//                                 height: 20,
//                               ),
//                               LHTextFormField(
//                                 labelText: 'Event Name',
//                                 initialValue: state.eventName,
//                                 backgroundColor: const Color(0xFFECEEF4),
//                                 maxLength: 50,
//                                 onChanged: (value) {
//                                   context
//                                       .read<CreateEventBloc>()
//                                       .add(EventNameChanged(eventName: value));
//                                 },
//                               ),
//                               const SizedBox(
//                                 height: 20,
//                               ),
//                               LHTextFormField(
//                                 labelText: 'Event Description',
//                                 initialValue: state.eventName,
//                                 backgroundColor: const Color(0xFFECEEF4),
//                                 maxLength: 100,
//                                 maxLines: 3,
//                                 onChanged: (value) {
//                                   context
//                                       .read<CreateEventBloc>()
//                                       .add(EventNameChanged(eventName: value));
//                                 },
//                               ),
//                             ],
//                           )),
//                       Flexible(
//                           flex: 2,
//                           child: Container(
//                             width: double.infinity,
//                             child:
//                                 LHButton(buttonText: 'NEXT', onPressed: () {}),
//                           ))
//                     ],
//                   ),
//                 )),
//           ))
//         ],
//       );
//     }));
//   }
// }
