

import 'package:d2_ai_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_base.dart';
import 'bloc_event_base.dart';
import 'bloc_state_base.dart';


abstract class StatelessWidgetWithBloc<
    B extends AdvancedBlocBase<E,GlobalState<S>>,
    E,
    S> extends StatelessWidget {

  final B bloc;

  const StatelessWidgetWithBloc({Key? key, required this.bloc}) : super(key: key);

  /// Метод будет вызываться каждый раз, когда меняется состояние на [newState]
  void onListen(S newState);

  /// Основное тело виджета
  Widget onStateLoaded(S newState);

  @mustCallSuper
  @protected
  void addEvent({required E event}) {
    bloc.add(event);
  }

  @protected
  @override
  Widget build(BuildContext context) {

    return BlocConsumer<B, GlobalState<S>>(
        bloc: bloc,
        builder: (context, state) {

          if (state is ResultStateBase) {
            return const SizedBox.shrink();
          }
          if (state is ErrorStateBase) {
            return _onError();
          }
          if (state is LoadingStateBase) {
            return _onLoading();
          }

          final content = state.getContent();
          if (content != null) {
            return onStateLoaded(content);
          }

          throw Exception();

          //return onStateLoaded(state.getContent()!);
        },
        listener: (context, state) {
          if (state is ResultStateBase) {
            _onResult(context: context, result: state.getResult());
            return;
          }
          if (state is ErrorStateBase) {
            return;
          }
          if (state is LoadingStateBase) {
            return;
          }
          final content = state.getContent();
          if (content != null) {
            onListen(content);
          }

        }
    );
  }

  Widget _onError() {
    return Container(color: Colors.green,);
  }

  Widget _onLoading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: UIColors.primary,),
      ),
    );
  }

  void _onResult({required BuildContext context, required dynamic result}) {
    Navigator.of(context).maybePop(result);
  }

}