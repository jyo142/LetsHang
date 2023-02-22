import 'package:flutter/material.dart';
import 'package:letshang/blocs/hang_event_participants/hang_event_participants_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/lh_button.dart';

class SearchParticipantsBy extends StatelessWidget {
  final String searchBy;
  final Function onChange;
  final Function onSubmit;

  const SearchParticipantsBy(
      {Key? key,
      required this.searchBy,
      required this.onChange,
      required this.onSubmit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(searchBy, style: Theme.of(context).textTheme.bodyText1),
            ],
          )),
      TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            fillColor: const Color(0xFFCCCCCC),
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
          initialValue: "",
          // The validator receives the text that the user has entered.
          validator: (value) {
            // return stateErrorMessage?.call(state);
          },
          onChanged: (value) => onChange(value)),
      BlocBuilder<HangEventParticipantsBloc, HangEventParticipantsState>(
          builder: (context, state) {
        if (state is SearchParticipantError) {
          return Container(
            margin: const EdgeInsets.only(top: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(state.errorMessage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .merge(const TextStyle(color: Color(0xFFD50000))))
            ]),
          );
        }
        return const SizedBox.shrink();
      }),
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 40),
        child: LHButton(buttonText: 'Search', onPressed: () => onSubmit()),
      )
    ]);
  }
}
