

import 'package:d2_ai_v2/bloc_base/bloc_base.dart';
import 'package:d2_ai_v2/bloc_base/bloc_state_base.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/screen/unit/unit_inforamtion/unit_information_event.dart';
import 'package:d2_ai_v2/screen/unit/unit_inforamtion/unit_information_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnitInformationBloc extends AdvancedBlocBase<
    UnitInformationEvent,
    GlobalState<UnitState>, UnitState> {

  final Unit unit;

  UnitInformationBloc({required this.unit}) : super(
      LoadingStateBase()) {

    on<UnitInformationInitialEvent>((event, emit) async {
      await handleEventWrapper(() async {
        await _onInit(event, emit);
      });
    });

  }

  Future<void> _onInit(UnitInformationInitialEvent event, Emitter<GlobalState<UnitState>> emit) async {
    print('INITIALIZATION EVENT');
    //await Future.delayed(const Duration(seconds: 1));
    final newState = UnitState(unit: unit);
    emit(newState.toContent());

  }

}