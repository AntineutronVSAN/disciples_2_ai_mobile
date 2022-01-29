

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
  const BaseState();

  ContentStateBase<T> toContent() => ContentStateBase(this as T);

  LoadingStateBase<T> toLoading() => LoadingStateBase();

  ErrorStateBase<T> toError(String error) => ErrorStateBase(error);
}


class LoadingStateBase<T> extends GlobalState<T> {}

class ErrorStateBase<T> extends GlobalState<T> {
  final String error;

  const ErrorStateBase(this.error);
}

class ContentStateBase<T> extends GlobalState<T> {
  final T content;

  const ContentStateBase(this.content);
}

class ResultStateBase<T> extends GlobalState<T> {
  final dynamic result;

  const ResultStateBase({this.result});
}
