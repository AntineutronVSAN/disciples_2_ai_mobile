
/// Глобальное состояние виждета
/// Используется как база для каждого конкретного состояния:
/// [LoadingStateBase] - Страница загружается. Для компонентов страницы
/// статус загрузки должен описываться в каждом конкретном состоянии [T]
/// [ContentStateBase] - Контент для страницы загружен, можно отображать
/// [ErrorStateBase] - Состояние страницы с ошибкой, однако контент также
/// имеется
/// [ResultStateBase] - Состояние, когда при навигации на страницу нужно
/// возвращать результат
/// [UnauthorizedStateBase] - Контент имеется, но авторизация слетела
abstract class GlobalState<T> {
  const GlobalState();

  T? getContent() {
    if (this is ContentStateBase<T>) {
      return (this as ContentStateBase<T>).content;
    } else {
      return null;
    }
  }

  bool isLoading() => this is LoadingStateBase<T>;

  String? getError() {
    if (this is ErrorStateBase<T>) {
      return (this as ErrorStateBase<T>).error;
    } else {
      return null;
    }
  }

  dynamic getResult() {
    if (this is ResultStateBase<T>) {
      return (this as ResultStateBase<T>).result;
    } else {
      return null;
    }
  }

}

class BaseState<T> {

  final bool? localLoading;

  const BaseState({this.localLoading});

  ContentStateBase<T> toContent() => ContentStateBase(this as T);

  LoadingStateBase<T> toLoading() => LoadingStateBase();

  ErrorStateBase<T> toError(String error) => ErrorStateBase(error, this as T);
}


class LoadingStateBase<T> extends GlobalState<T> {}



class ContentStateBase<T> extends GlobalState<T> {
  final T content;
  const ContentStateBase(this.content);
}

class ErrorStateBase<T> extends ContentStateBase<T> {
  final String error;
  const ErrorStateBase(this.error, T content) : super(content);
}

class ResultStateBase<T> extends GlobalState<T> {
  final dynamic result;
  const ResultStateBase({this.result});
}

class UnauthorizedStateBase<T> extends ContentStateBase<T> {

  const UnauthorizedStateBase(T content): super(content);
}
