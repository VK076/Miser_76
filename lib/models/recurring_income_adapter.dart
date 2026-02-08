import 'package:hive/hive.dart';
import '../models/recurring_income.dart';

class RecurringIncomeAdapter extends TypeAdapter<RecurringIncome> {
  @override
  final int typeId = 4;

  @override
  RecurringIncome read(BinaryReader reader) {
    return RecurringIncome(
      id: reader.readString(),
      source: reader.readString(),
      amount: reader.readDouble(),
      description: reader.readString(),
      startDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      endDate: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
      frequency: reader.readString(),
      lastCreated: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isActive: reader.readBool(),
      walletId: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, RecurringIncome obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.source);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.description);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);
    writer.writeBool(obj.endDate != null);
    if (obj.endDate != null) {
      writer.writeInt(obj.endDate!.millisecondsSinceEpoch);
    }
    writer.writeString(obj.frequency);
    writer.writeInt(obj.lastCreated.millisecondsSinceEpoch);
    writer.writeBool(obj.isActive);
    writer.write(obj.walletId);
  }
}
