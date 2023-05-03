import 'package:equatable/equatable.dart';

class AppMetadataState extends Equatable {
  const AppMetadataState({this.pageIndex = 0});
  final int pageIndex;

  AppMetadataState copyWith({int? pageIndex}) {
    return AppMetadataState(
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }

  @override
  List<Object?> get props => [pageIndex];
}
