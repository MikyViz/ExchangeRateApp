import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future fetchExchangeRate(String fromCurrency, String toCurrency) async {
  //TODO ТИПИЗАЦИЯ!!!!! какой тип ожидается от функции? double? или обьект???
  const apiKey =
      'fca_live_PwKHMUvyTedGGvpShpMgfy4SDOKzhNCZQcUhAa31'; //! MUST TO USE ENV VARIABLES
  final url = Uri.parse(
      'https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey&currencies=$toCurrency&base_currency=$fromCurrency');
  final urlOverview = Uri.parse(
      'https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey&currencies=&base_currency=$fromCurrency');

  try {
    var response;
    if (toCurrency.isEmpty) {
      //? В этом блоке, есть противоречащие условия... но сука работает🤔
      response = await http.get(urlOverview);
    } else {
      response = await http.get(url);
    }
    print(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (toCurrency != '')
        return data['data'][toCurrency] as double?;
      else
        return data['data'];
    } else {
      print('Failed to load exchange rate');
    }
  } catch (e) {
    print('Error: $e');
  }
  return null;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money?',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 70, 9, 103)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> currencies = [];

  final TextEditingController myIconController = TextEditingController();
  final TextEditingController targetIconController = TextEditingController();
  final TextEditingController amountBaseController = TextEditingController();
  final TextEditingController amountTagetController = TextEditingController();

  String? mySelectedIcon; // TODO Specify the type
  String? targetSelectedIcon; // TODO Specify the type

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    const apiKey =
        'fca_live_PwKHMUvyTedGGvpShpMgfy4SDOKzhNCZQcUhAa31'; //! MUST TO USE ENV VERIABLE
    final url = Uri.parse(
        'https://api.freecurrencyapi.com/v1/currencies?apikey=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        data.forEach((key, value) {
          setState(() {
            currencies.add({
              'code': key,
              'symbol': value['symbol_native'],
              'name': value['name']
            });
          });
        });
        print(currencies);
      } else {
        print('Failed to load currencies');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('How much does your money cost?'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://th.bing.com/th/id/OIG3.K0OamqqO347g5h4ZanEH?pid=ImgGn'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 300,
              height: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  DropdownButtonFormField( 
                    decoration: InputDecoration(
                      labelText: 'Your currency',
                      prefixIcon: Icon(Icons.wallet),
                      filled: true,
                      fillColor: const Color.fromARGB(205, 255, 255, 255),
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: currencies.map<DropdownMenuItem<String>>((currency) {
                      return DropdownMenuItem<String>(
                        value: currency['code'],
                        child: Text(
                            '${currency['name']} ${currency['code']} ${currency['symbol']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        mySelectedIcon = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: amountBaseController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(205, 255, 255, 255),
                        labelText: 'How many to change?',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Target currency',
                      //add icon in labele
                      prefixIcon: Icon(Icons.my_location),
                      filled: true,
                      fillColor: const Color.fromARGB(205, 255, 255, 255),
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: currencies.map<DropdownMenuItem<String>>((currency) {
                      return DropdownMenuItem<String>(
                        value: currency['code'],
                        child: Text(
                            '${currency['name']} ${currency['code']} ${currency['symbol']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        targetSelectedIcon = value;
                      });
                    },
                  ),
                  //TODO: В будущем сделать поле для ввода суммы в целевой валюте и при вводе в одно из окон ввода, чтобы второе окно становилось недоступным

                  const SizedBox(height: 24),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(202, 104, 58, 183),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (mySelectedIcon != null &&
                            targetSelectedIcon != null) {
                          final exchangeRate = await fetchExchangeRate(
                            mySelectedIcon!,
                            targetSelectedIcon!,
                          );
                          if (exchangeRate != null) {
                            double amountInTargetCurrency =
                                double.parse(amountBaseController.text) *
                                    exchangeRate;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Exchange Rate'),
                                  content: Text(
                                      '${amountBaseController.text} ${mySelectedIcon!} =  $amountInTargetCurrency ${targetSelectedIcon!}'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          // TODO: Обработай случай, когда валюты не выбраны
                          print('Please select both currencies.');
                        }
                      },
                      child: const Text(
                        'GO!',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(202, 104, 58, 183),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (mySelectedIcon != null) {
                          final exchangeRate = await fetchExchangeRate(
                            mySelectedIcon!,
                            '',
                          );
                          if (exchangeRate != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OverviewRoute(
                                        data: exchangeRate,
                                      )),
                            );
                          }
                        } else {
                          // TODO: Обработай случай, когда валюты не выбраны
                          print('Please select your currency.');
                        }
                      },
                      child: const Text(
                        'Rate overwiev',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class OverviewRoute extends StatelessWidget {
  final Map<String, dynamic> data;
  const OverviewRoute({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Rate overwiev🤑'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
            child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://theop.games/cdn/shop/products/NationalParks_MN_2020_money_graphic_600x600_crop_center.jpg?v=1654793811'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 400,
                    height: 300,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final currency = data.keys.elementAt(index);
                        final rate = data[currency];
                        // final name = currency['name'];
                        return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              title: Text(
                                '$currency: $rate', //TODO В перспективе сделать так, чтобы отображались и названия валют. Требует больших усилий чем кажется на первый взгляд, по тому, что возвращаемый с сервера ответ, не включает названия валют. Имена содержатся в ответе на запрос посылаемый при загрузке апликации.
                                style: TextStyle(color: Colors.black),
                              ),
                            ));
                      },
                    ),
                  ),
                ))));
  }
}
