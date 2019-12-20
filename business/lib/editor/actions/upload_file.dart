import '../../app_state.dart';
import 'editing_base_action.dart';

class UploadFileAction extends EditingBaseAction {
  final int categoryId;
  final int index;

  UploadFileAction(this.categoryId, this.index);

  @override
  Future<AppState> reduce() async {
    assert(editingState.initialized);
    assert(editingState.files[index].isUploading);

    final res = await state.repository.uploadFile(
      file: editingState.files[index].file,
      uploadUrl: editingState.uploadUrl,
      auth: editingState.uploadAuthCode,
      categoryId: categoryId,
    );

    return state.rebuild(
      (b) => b.editingState.files[index] =
          b.editingState.files[index].rebuild((b) => b
            ..uploaded = true
            ..isUploading = false
            ..check = res.attachChecksum
            ..code = res.attachCode
            ..url = res.attachUrl),
    );
  }

  void before() => dispatch(_SetUploadingAction(index));
}

class _SetUploadingAction extends EditingBaseAction {
  final int index;

  _SetUploadingAction(this.index);

  @override
  AppState reduce() {
    assert(editingState.initialized);
    assert(!editingState.files[index].uploaded);

    return state.rebuild((b) => b.editingState.files[index] =
        b.editingState.files[index].rebuild((b) => b.isUploading = true));
  }
}
