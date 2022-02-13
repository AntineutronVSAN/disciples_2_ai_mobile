

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'bloc_base.dart';
import 'bloc_state_base.dart';

abstract class StateFullWidgetWithBloc<B> extends StatefulWidget {
  final B bloc;
  B getBloc() {
    return bloc;
  }
  const StateFullWidgetWithBloc({Key? key, required this.bloc}) : super(key: key);
}

abstract class StatefulWidgetStateWithBloc<
T extends StateFullWidgetWithBloc<B>,
B extends AdvancedBlocBase<E, GlobalState<S>, S>,
E,
  S> extends State<T> {
  late final B bloc;

  StatefulWidgetStateWithBloc({Key? key})
      : super();

  @mustCallSuper
  @override
  void initState() {
    bloc = widget.getBloc();
    super.initState();
  }

  /// Метод будет вызываться каждый раз, когда меняется состояние на [newState]
  void onListen(S newState, BuildContext context);

  /// Метод вызывается при протухании или некорректности токенов
  void onTokenExpired(BuildContext context);

  /// Основное тело виджета
  Widget onStateLoaded(S newState, BuildContext context);

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
            //return _onError();
          }
          if (state is LoadingStateBase) {
            return onLoading();
          }

          final content = state.getContent();
          if (content != null) {
            return onStateLoaded(content, context);
          }

          throw Exception();
        },
        listener: (context, state) {
          if (state is ResultStateBase) {
            onResult(context: context, result: state.getResult());
            return;
          }
          if (state is ErrorStateBase) {

            final snackBar = SnackBar(
              content: Text(state.getError() ?? 'Неизвестная ошибка'),
              /*action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),*/
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);

            return;
          }
          if (state is LoadingStateBase) {
            return;
          }
          if (state is UnauthorizedStateBase) {
            onTokenExpired(context);
          }
          final content = state.getContent();
          if (content != null) {
            onListen(content, context);
          }
        });
  }

  Widget onError();
  Widget onLoading();
  void onResult({required BuildContext context, required dynamic result});
}

/// Конкретная реализация [StatelessWidgetWithBloc] для приложения SScore
abstract class D2StatefulWidgetState<
T extends StateFullWidgetWithBloc<B>,
B extends AdvancedBlocBase<E, GlobalState<S>, S>,
E,
S> extends StatefulWidgetStateWithBloc<T, B, E, S> {

  D2StatefulWidgetState({Key? key}) : super(key: key);

  @override
  void onTokenExpired(BuildContext context) async {
    // TODO Add here token expited handling
  }

  @override
  Widget onError() {
    return Container(
      color: Colors.green,
    );
  }

  @override
  Widget onLoading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
        ),
      ),
    );
  }

  @override
  void onResult({required BuildContext context, required dynamic result}) {
    Navigator.of(context).maybePop(result);
  }

}