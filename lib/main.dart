import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// TODO Разбить на функции и файлы, весь этот ахрененно длинный код!!!!

Future fetchExchangeRate(String fromCurrency, String toCurrency) async {
  const apiKey =
      'fca_live_PwKHMUvyTedGGvpShpMgfy4SDOKzhNCZQcUhAa31'; //! MUST TO USE ENV VARIABLES
  final url = Uri.parse(
      'https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey&currencies=$toCurrency&base_currency=$fromCurrency');
  final urlOverview = Uri.parse(
      'https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey&currencies=&base_currency=$fromCurrency');

  try {
    http.Response response; // TODO have to understand wtf type of response ...
    if (toCurrency.isEmpty) {
      response = await http.get(urlOverview);
    } else {
      response = await http.get(url);
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(
          response.body); // TODO have to understand wtf type of data ...

      if (toCurrency != '') {
        return data['data'][toCurrency] as double?;
      } else {
        return data['data'];
      }
    } else {
      print('Failed to load exchange rate');
    }
  } catch (e) {
    print('🤦‍♂️Error: $e');
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
      title: 'money sale!',
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

  // final TextEditingController myIconController = TextEditingController(); // TOdo Проверить, возможно нужно использовать
  // final TextEditingController targetIconController = TextEditingController();
  final TextEditingController amountBaseController =
      TextEditingController(); // todo 👇to chack using of those var
  final TextEditingController amountTagetController = TextEditingController();

  String? mySelectedIcon;
  String? targetSelectedIcon; // TODO  ☝️☝️☝️☝️☝️☝️☝️☝️☝️

  @override
  void initState() {
    // Выполняет нижеуказанные команды при загрузке страници
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
      } else {
        print(
            'Failed to load currencies'); //todo выяснить про logging framework
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
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
                      prefixIcon: const Icon(Icons.wallet),
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
                        value:
                            currency['code'], //? what different from a child?
                        child: Text(
                            '${currency['name']} ${currency['code']} ${currency['symbol']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        mySelectedIcon =
                            value; // * Это СцуКа нада перадать в раут, мать его...
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
                        prefixIcon: Icon(Icons.shopping_basket),
                        // prefixIcon: Icon(Icons.add_shopping_cart),
                        // prefixIcon: Icon(Icons.price_change),
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
                      prefixIcon: Icon(Icons.add_shopping_cart),
                      // prefixIcon: Icon(Icons.my_location),
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
                        backgroundColor:
                            const Color.fromARGB(202, 104, 58, 183),
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
                            final currentContext = context;
                            double amountInTargetCurrency =
                                double.parse(amountBaseController.text) *
                                    exchangeRate;
                            if (mounted) {
                              showDialog(
                                context:
                                    currentContext, // todo лучше неиспользовать контекст, реши эту проблему, и разберись с тем, почему это проблемма.
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Exchange Rate'),
                                    content: Text(
                                        '${amountBaseController.text} ${mySelectedIcon!} =  $amountInTargetCurrency ${targetSelectedIcon!}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
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
                        backgroundColor:
                            const Color.fromARGB(202, 104, 58, 183),
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
                                        data:
                                            exchangeRate, // *****Сука, здесь блядь ты нахуй передаешь аргументы в сраный овервью виджет нахуй.
                                        currencies: currencies,
                                        myCurrency: mySelectedIcon!,
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
  final List<Map<String, String>> currencies;
  final String  myCurrency;

  const OverviewRoute(
      {super.key,
      required this.data,
      required this.currencies,
      required this.myCurrency});


  @override
  Widget build(BuildContext context) {
      final Map<String, String> myCurrencyInfo = currencies.firstWhere(
                          (currency) => currency['code'] == myCurrency,
                          orElse: () => {
                            'name': 'Unknown',
                            'symbol': ''
                          }, // На случай отсутствия данных
                        );
    return Scaffold(
        appBar: AppBar(
        title: Text('${myCurrencyInfo['name']} ${myCurrencyInfo['symbol']} ${myCurrencyInfo['code']}'),
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
                        final currencyCode = data.keys.elementAt(index);
                        final rate = data[currencyCode];

                        // Найди информацию о валюте по её коду
                        final currencyInfo = currencies.firstWhere(
                          (currency) => currency['code'] == currencyCode,
                          orElse: () => {
                            'name': 'Unknown',
                            'symbol': ''
                          }, // На случай отсутствия данных
                        );

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
                                '${currencyInfo['name']} (${currencyInfo['symbol']}) - $currencyCode: $rate',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ));
                      },
                    ),
                  ),
                ))));
  }
}
