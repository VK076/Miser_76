import 'package:hive/hive.dart';
import 'income.dart';

class IncomeAdapter extends TypeAdapter<Income> {
  @override
  final int typeId = 2; // Unique ID for this type

  @override
  Income read(BinaryReader reader) {
    return Income(
      id: reader.readString(),
      amount: reader.readDouble(),
      source: reader.readString(),
      description: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isRecurring: reader.readBool(),
      walletId: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Income obj) {
    writer.writeString(obj.id);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.source);
    writer.writeString(obj.description);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.isRecurring);
    writer.write(obj.walletId);
  }
}
