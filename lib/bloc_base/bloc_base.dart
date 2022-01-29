

import 'package:d2_ai_v2/bloc_base/bloc_state_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_event_base.dart';


abstract class AdvancedBlocBase<E, S> extends Bloc<E, S> {

  /// Если [eventsQueue] == false, то в таком случае пока блок обратывает
  /// событие, новые события не принимаются
  final bool eventsQueue;

  /// Если [eventsQueue] == false, может ли сейчас блок принять в обработку
  /// новое событие
  bool _canAcceptNewEvent = true;

  AdvancedBlocBase(S initialState, {
    this.eventsQueue = false,
  }) : super(initialState);

  /// Враппер позволяет перехватить новое событие и проверить, можно ли
  /// событие брать в обработку
  Future<void> handleEventWrapper(Function() func) async {
    if (_canAcceptNewEvent) {
      _canAcceptNewEvent = false;
      await func();
      _canAcceptNewEvent = true;
    }
  }

 /* void registerNewEvent<UE extends E>(Function(UE event, Emitter emit) handler) {
    print('1213');
    on<UE>((event, emit) => _handleEventWrapper(() => handler));
  }*/

  /*on<OnPVPStartedEvent>(
    (event, emit) => _handleEvent(() => _onPVPStarted(event, emit)));*/

}