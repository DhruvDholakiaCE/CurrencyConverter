import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

void main() {
  runApp(MaterialApp(
    home: Scrapper(),
  ));
}


class Scrapper extends StatefulWidget {
  @override
  _ScrapperState createState() => _ScrapperState();

}

class _ScrapperState extends State<Scrapper> {

  static List<String> currency = ['EUR', 'USD','GBP','CHF','CAD','JPY','AUD','INR'];
  static List<String> symbols = ['€',  '\$',  '£',   '₣',  '\$', '¥',  '\$','₹'];

  _ScrapperState() {
    scrappingContent(dropdownValueFrom, dropdownValueTo).then((value) {setState(() {
      unitValue = value; print(value); enabled =true;
    });});
  }

  Future<String> scrappingContent(String from, String to) async{
    try {
      final webScraper = WebScraper('https://www.x-rates.com');
      if (await webScraper.loadWebPage(
          '/calculator/?from=$from&to=$to&amount=1')) {
        var content = webScraper.getElement(
            '#content > div:nth-child(1) > div > div:nth-child(1) > div > div > span.ccOutputRslt',
            ['title']);
        print(content);
        String fileInfo = content[0]['title'].split(',')[0].split(' ')[0];
        return fileInfo;
      }
    }
    catch(e){
      print(e);
    }
  }

  bool loading = false;
  String dropdownValueFrom = currency[1];
  String dropdownValueTo = currency[7];
  String symbolFrom = symbols[1];
  String symbolTo = symbols[7];
  String convertedValue = '';
  String unitValue= '';
  bool enabled = false;
  TextEditingController inputController = new TextEditingController();
  double _currentValue = 0;
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Text('Currency Converter', style: TextStyle(fontSize: 25),),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: IconButton(
              icon: Icon(
                Icons.calculate,
                size: 40,
                color: Colors.white,
              ),
              splashColor: Colors.white,
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: calc());
                    });
              },
            ),
          )
        ],
      ),

      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 120.0, 10.0, 0.0),
        child: Material(
          elevation: 15.0,

          // borderRadius: BorderRadius.only( topLeft: Radius.circular(80.0),  bottomRight: Radius.circular(80.0) ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,

            decoration: BoxDecoration(
              color: Colors.amber,
              // borderRadius: BorderRadius.only(
              //     topLeft: Radius.circular(80.0),
              //     bottomRight: Radius.circular(80.0)
              //   ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children : [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 55,
                          color: Colors.grey[200],
                          child: loading ? loadingCircle(): Center(child: Text('$convertedValue', style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w500),))
                      ),
                    ]
                ),
                SizedBox(height: 5,),
                unitValue == '' ? Text(''): Text('1 ' + dropdownValueFrom + ' = ' + double.parse(unitValue).toStringAsFixed(2) + ' ' + dropdownValueTo, style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                // SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: dropdownValueFrom,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),

                      onChanged: (String newValue) async{

                        setState(() {
                          dropdownValueFrom = newValue;
                          symbolFrom = symbols[currency.indexOf(newValue)];
                          convertedValue = '';
                          loading = true;
                          enabled = false;
                        });

                        await scrappingContent(dropdownValueFrom, dropdownValueTo).then((value) => unitValue = value);
                        setState(() {
                          loading = false;
                          enabled = true;
                          if(inputController.text.isNotEmpty){
                            String inputValue = inputController.text;
                            convertedValue = (double.parse(unitValue) * double.parse(inputValue)).toStringAsFixed(2);
                          }
                        });
                      },
                      items: currency.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 20),),
                        );
                      }).toList(),
                    ),

                    SizedBox(width: 10,),

                    Text('$symbolFrom', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.blue),),

                    SizedBox(width: 40,),

                    Icon(Icons.arrow_right_alt_sharp, size: 65, color: Colors.deepPurple,),

                    SizedBox(width: 40,),

                    Text('$symbolTo', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.blue),),

                    SizedBox(width: 10,),

                    DropdownButton<String>(
                      value: dropdownValueTo,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) async{

                        setState(() {
                          dropdownValueTo = newValue;
                          symbolTo = symbols[currency.indexOf(newValue)];
                          convertedValue = '';
                          loading = true;
                          enabled = false;
                        });

                        await scrappingContent(dropdownValueFrom, dropdownValueTo).then((value) => unitValue = value);
                        setState(() {
                          loading = false;
                          enabled = true;
                          if(inputController.text.isNotEmpty){
                            String inputValue = inputController.text;
                            convertedValue = (double.parse(unitValue) * double.parse(inputValue)).toStringAsFixed(2);
                          }

                        });
                      },
                      items: currency.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 20),),
                        );
                      }).toList(),
                    ),

                  ],
                ),
                SizedBox(height: 10 ,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextFormField(

                      enabled: enabled,
                      //validation logic
                      autovalidateMode: AutovalidateMode.always,
                      validator: (input) {
                        final isDigitsOnly = input.isEmpty? '1':double.tryParse(input);
                        return isDigitsOnly == null
                            ? 'Input needs to be digits only'
                            : null;
                      },

                      style: TextStyle(fontSize: 17),
                      controller: inputController,

                      //border decoration for error, focus, enable
                      decoration: InputDecoration(

                        isDense: true,
                        contentPadding: EdgeInsets.all(15.0),
                        labelText: 'Amount',

                        //focused border
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: const BorderSide(color: Colors.purple, width: 2.0),
                        ),

                        //error border
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),

                        focusedErrorBorder: new OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: new BorderSide(color: Colors.red, width: 2.0),
                        ),

                        //enable disable border
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: const BorderSide(color: Color(0xff3081f9), width: 2.0),
                        ),

                        disabledBorder:  const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                        ),

                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                RaisedButton(
                    color: Colors.blue[400],
                    child: Text('Convert', style: TextStyle(color: Colors.white, fontSize: 20),),
                    elevation: 10,
                    onPressed: () async{
                      if(unitValue == ''){
                        setState(() {
                          loading = true;
                          enabled = false;
                        });
                        await scrappingContent(dropdownValueFrom, dropdownValueTo).then((value) => unitValue = value);
                        setState(() {
                          loading = false;
                          enabled = true;
                        });
                      }
                      setState(() {
                        if(inputController.text.isNotEmpty){
                          print('we are here');
                          String inputValue = inputController.text;
                          convertedValue = (double.parse(unitValue) * double.parse(inputValue)).toStringAsFixed(2);
                        }
                      });

                    }

                )
              ],
            ),
          ),
        ),
      ),
    );

  }
}

Widget calc(){
  return SimpleCalculator(
    value: 0,
    hideExpression: false,
    hideSurroundingBorder: true,
    onChanged: (key, value, expression) {

      print("$key\t$value\t$expression");
    },
    onTappedDisplay: (value, details) {
      print("$value\t${details.globalPosition}");
    },
    theme: const CalculatorThemeData(
      borderColor: Colors.black,
      borderWidth: 2,
      displayColor: Colors.black,
      displayStyle: const TextStyle(fontSize: 80, color: Colors.yellow),
      expressionColor: Colors.indigo,
      expressionStyle: const TextStyle(fontSize: 20, color: Colors.white),
      operatorColor: Colors.pink,
      operatorStyle: const TextStyle(fontSize: 30, color: Colors.white),
      commandColor: Colors.orange,
      commandStyle: const TextStyle(fontSize: 30, color: Colors.white),
      numColor: Colors.grey,
      numStyle: const TextStyle(fontSize: 50, color: Colors.white),
    ),
  );
}


Widget loadingCircle(){
  return SpinKitFadingCircle(
    size: 40,
    color: Colors.amber,
  );
}

