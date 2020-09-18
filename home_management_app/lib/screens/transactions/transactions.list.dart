import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/main-card.dart';
import 'package:home_management_app/models/transaction.dart';
import 'package:home_management_app/repositories/category.repository.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'package:home_management_app/services/transaction.paging.service.dart';
import 'package:intl/intl.dart';

class TransactionListWidget extends StatefulWidget {
  final int accountId;

  TransactionListWidget(this.accountId);

  @override
  _TransactionListWidgetState createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  CategoryRepository categoryRepository = GetIt.I<CategoryRepository>();
  TransactionPagingService transactionPagingService = GetIt.I<TransactionPagingService>();
  TransactionRepository transactionRepository = GetIt.I<TransactionRepository>();

  List<TransactionModel> transctions = List<TransactionModel>();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(onScroll);
    transactionPagingService.addListener(load);
    transactionPagingService.loadFirstPage(widget.accountId);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    transactionPagingService.removeListener(load);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          transactionPagingService.refresh();
          await transactionPagingService.loadFirstPage(widget.accountId);
          this.load();
        },
        child: MainCard(
          child: transctions.length > 0
              ? ListView.builder(
                  controller: scrollController,
                  itemCount: this.transctions.length,
                  itemBuilder: (context, index) {
                    var transaction =
                        this.transactionPagingService.transactions[index];
                    var category = categoryRepository.categories.firstWhere(
                        (element) => element.id == transaction.categoryId);

                    return Dismissible(
                      key: Key(transaction.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.blueAccent,
                      ),
                      secondaryBackground: Container(
                        color: Colors.redAccent,
                      ),
                      onDismissed: (direction) => remove(transaction, index),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(transaction.name),
                                  Text(
                                    transaction.price.toStringAsFixed(0),
                                    style: TextStyle(
                                        color: transaction.transactionType ==
                                                TransactionType.Income
                                            ? Colors.greenAccent
                                            : Colors.redAccent),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                                  child: Text(
                                    DateFormat.MMMd().format(transaction.date),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                                  child: Chip(
                                    label: Text(category.name),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  })
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text('No transactions to display.'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  load() {
    setState(() {
      transctions.clear();
      transctions.addAll(transactionPagingService.transactions);
    });
  }

  nextPage() {
    setState(() {
      transactionPagingService.nextPage();
      load();
    });
  }

  onScroll() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      nextPage();
    }

    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      print('reached top');
    }
  }

  Future remove(item, index) async {
    try {
      this.transactionRepository.remove(item);
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(item.name + ' removed')));
    } catch (ex) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove ${item.name}')));
    }
  }
}
