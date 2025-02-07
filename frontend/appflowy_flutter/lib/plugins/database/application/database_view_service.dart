import 'package:appflowy/plugins/database/application/row/row_service.dart';
import 'package:appflowy_backend/dispatch/dispatch.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-error/errors.pb.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:dartz/dartz.dart';

import 'layout/layout_service.dart';

class DatabaseViewBackendService {
  DatabaseViewBackendService({required this.viewId});

  final String viewId;

  /// Returns the datbaase id associated with the view.
  Future<Either<String, FlowyError>> getDatabaseId() async {
    final payload = DatabaseViewIdPB(value: viewId);
    return DatabaseEventGetDatabaseId(payload)
        .send()
        .then((value) => value.leftMap((l) => l.value));
  }

  static Future<Either<ViewPB, FlowyError>> updateLayout({
    required String viewId,
    required DatabaseLayoutPB layout,
  }) {
    final payload = UpdateViewPayloadPB.create()
      ..viewId = viewId
      ..layout = viewLayoutFromDatabaseLayout(layout);

    return FolderEventUpdateView(payload).send();
  }

  Future<Either<DatabasePB, FlowyError>> openDatabase() async {
    final payload = DatabaseViewIdPB(value: viewId);
    return DatabaseEventGetDatabase(payload).send();
  }

  Future<Either<Unit, FlowyError>> moveGroupRow({
    required RowId fromRowId,
    required String fromGroupId,
    required String toGroupId,
    RowId? toRowId,
  }) {
    final payload = MoveGroupRowPayloadPB.create()
      ..viewId = viewId
      ..fromRowId = fromRowId
      ..fromGroupId = fromGroupId
      ..toGroupId = toGroupId;

    if (toRowId != null) {
      payload.toRowId = toRowId;
    }

    return DatabaseEventMoveGroupRow(payload).send();
  }

  Future<Either<Unit, FlowyError>> moveRow({
    required String fromRowId,
    required String toRowId,
  }) {
    final payload = MoveRowPayloadPB.create()
      ..viewId = viewId
      ..fromRowId = fromRowId
      ..toRowId = toRowId;

    return DatabaseEventMoveRow(payload).send();
  }

  Future<Either<Unit, FlowyError>> moveGroup({
    required String fromGroupId,
    required String toGroupId,
  }) {
    final payload = MoveGroupPayloadPB.create()
      ..viewId = viewId
      ..fromGroupId = fromGroupId
      ..toGroupId = toGroupId;

    return DatabaseEventMoveGroup(payload).send();
  }

  Future<Either<List<FieldPB>, FlowyError>> getFields({
    List<FieldIdPB>? fieldIds,
  }) {
    final payload = GetFieldPayloadPB.create()..viewId = viewId;

    if (fieldIds != null) {
      payload.fieldIds = RepeatedFieldIdPB(items: fieldIds);
    }
    return DatabaseEventGetFields(payload).send().then((result) {
      return result.fold((l) => left(l.items), (r) => right(r));
    });
  }

  Future<Either<DatabaseLayoutSettingPB, FlowyError>> getLayoutSetting(
    DatabaseLayoutPB layoutType,
  ) {
    final payload = DatabaseLayoutMetaPB.create()
      ..viewId = viewId
      ..layout = layoutType;
    return DatabaseEventGetLayoutSetting(payload).send();
  }

  Future<Either<Unit, FlowyError>> updateLayoutSetting({
    required DatabaseLayoutPB layoutType,
    BoardLayoutSettingPB? boardLayoutSetting,
    CalendarLayoutSettingPB? calendarLayoutSetting,
  }) {
    final payload = LayoutSettingChangesetPB.create()
      ..viewId = viewId
      ..layoutType = layoutType;

    if (boardLayoutSetting != null) {
      payload.board = boardLayoutSetting;
    }

    if (calendarLayoutSetting != null) {
      payload.calendar = calendarLayoutSetting;
    }

    return DatabaseEventSetLayoutSetting(payload).send();
  }

  Future<Either<Unit, FlowyError>> closeView() {
    final request = ViewIdPB(value: viewId);
    return FolderEventCloseView(request).send();
  }

  Future<Either<RepeatedGroupPB, FlowyError>> loadGroups() {
    final payload = DatabaseViewIdPB(value: viewId);
    return DatabaseEventGetGroups(payload).send();
  }
}
