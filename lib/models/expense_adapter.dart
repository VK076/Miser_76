import 'package:hive/hive.dart';
import 'expense.dart';

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0; // Unique ID for this type

  @override
  Expense read(BinaryReader reader) {
    return Expense(
      id: reader.readString(),
      amount: reader.readDouble(),
      category: reader.readString(),
      description: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isAvoidable: reader.readBool(),
      walletId: reader.read(), // Read dynamic/nullable
      goalId: reader.read(),   // Read dynamic/nullable
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeString(obj.id);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.category);
    writer.writeString(obj.description);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.isAvoidable);
    writer.write(obj.walletId); // Write dynamic/nullable
    writer.write(obj.goalId);   // Write dynamic/nullable
  }
}

