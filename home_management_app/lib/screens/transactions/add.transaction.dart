import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/dropdown.component.dart';
import 'package:home_management_app/custom/input.factory.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/category.repository.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  static const String id = 'add_transaction_screen';

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionRepository transactionRepository =
      GetIt.I<TransactionRepository>();
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TextEditingController nameController = TextEditingController();

  double price = 0;
  CategoryModel selectedCategory;
  TransactionType selectedTransactionType = TransactionType.Income;
  DateTime selectedDate = DateTime.now();

  Function onAdd = null;

  @override
  void initState() {
    super.initState();
    selectedCategory = categoryRepository.categories.first;
    nameController.addListener(onNameChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Transaction'),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  buildFirstRow(),
                  buildSecondRow(),
                  buildThirdRow(),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: OutlineButton(
                        onPressed: onAdd,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Add'),
                            Icon(Icons.add),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding buildFirstRow() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: nameController,
        keyboardType: TextInputType.name,
        decoration:
            InputFactory.createdRoundedOutLineDecoration('Transaction Name'),
      ),
    );
  }

  Padding buildSecondRow() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                decoration: InputDecoration(icon: Icon(Icons.attach_money)),
                onChanged: (value) {
                  price = value.length > 0 ? double.parse(value) : 0;
                  checkIfShouldEnableButton();
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: DateTimeField(
                decoration: InputDecoration(
                  icon: Icon(Icons.date_range),
                ),
                format: DateFormat("dd MMM yyyy"),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
                onChanged: (date) {
                  selectedDate = date;
                },
                resetIcon: null,
                initialValue: DateTime.now(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Padding buildThirdRow() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: DropdownComponent(
                  items:
                      categoryRepository.categories.map((e) => e.name).toList(),
                  onChanged: (categoryName) {
                    selectedCategory = categoryRepository.categories
                        .firstWhere((element) => element.name == categoryName);
                    checkIfShouldEnableButton();
                  },
                )),
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: DropdownComponent(
                  items: TransactionModel.getTransactionTypes(),
                  onChanged: (transactionType) {
                    selectedTransactionType =
                        TransactionModel.parseByName(transactionType);
                  },
                )),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    this.nameController.removeListener(onNameChanged);
    this.nameController.dispose();
    super.dispose();
  }

  void onNameChanged() {
    print(nameController.text);
    checkIfShouldEnableButton();
  }

  void checkIfShouldEnableButton() {
    var shouldEnable =
        nameController.text.length > 0 && selectedCategory != null && price > 0;
    setState(() {
      onAdd = shouldEnable ? addTransaction : null;
    });
  }

  Future addTransaction() async {}
}
