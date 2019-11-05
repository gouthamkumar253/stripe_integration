import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// Note: The functions will work only if the Publishable key and merchantId is configured correctly.
// Also, since the application requires the payment intent to be created and confirmed in the backend,
// it is advised to try out the functionalities after completing the server-side code

class _MyHomePageState extends State<MyHomePage> {
  final cards = [
    {
      'cardNo': 'xxxx xxxx xxxx 3875',
      'cardType': 'master',
      'expiryDate': '12/24',
      'paymentMethodId': 'pm_visa',
    },
    {
      'cardNo': 'xxxx xxxx xxxx 7275',
      'cardType': 'visa',
      'expiryDate': '1/28',
      'paymentMethodId': 'pm_master',
    }
  ];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: 'YOUR_PUBLIC_KEY',
        merchantId: 'YOUR_MERCHANT_ID',
        androidPayMode: 'test',
      ),
    );
    super.initState();
  }

  void setError(Error error) {
    //Handle failed transactions and errors in this method
    print('Error---------- ${error.toString()}');
  }

  Future<void> connectToStripe(String paymentMethodId) async {
    print(paymentMethodId);
    const String url = 'YOUR_SERVER_URL';
    PaymentMethod paymentMethod = PaymentMethod();
    if (paymentMethodId == null) {
      paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      ).then((PaymentMethod paymentMethod) {
        return paymentMethod;
      }).catchError(setError);
    }
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));

//          Use this code to send the paymentMethod id to the server.
//          Create a paymentIntent in the server and return that object in the response

//          final http.Response response = await http.post(
//            '$url',
//            headers: <String, String>{
//              HttpHeaders.contentTypeHeader: 'application/json',
//              'access-token': accessToken,
//              'uid': uid,
//              'client': client,
//            },
//            body: json.encode(paymentMethod.id),
//          );
//          PaymentIntent paymentIntent = PaymentIntent.fromRawJson(response.body);

//          You have to check for the response from the server. If the card's bank needs authentication,
//          the paymentIntent object will have the status as 'requires_action'. If that's the case,
//          only then you have to perform the following steps. Else , if the paymentIntent has been confirmed,
//          you can directly show a success message and terminate the checkout.

    await StripePayment.authenticatePaymentIntent(
      clientSecret: 'CLIENT_SECRET_FROM_SERVER',
    ).then(
      //This code will be executed if the authentication is successful

      (PaymentIntentResult paymentIntentResult) async {
        print(paymentIntentResult.toJson());
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
                'Successful authentication.Status- ${paymentIntentResult.status}')));

//              final http.Response response = await http.post(
//                '$url',
//                headers: <String, String>{
//                  HttpHeaders.contentTypeHeader: 'application/json',
//                  'access-token': accessToken,
//                  'uid': uid,
//                  'client': client,
//                },
//                body: postToJson(data),
//              );
      },
      //If Authentication fails, a PlatformException will be raised which can be handled here
    ).catchError(setError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Payments with Flutter',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'ProximaNovaSemiBold',
            ),
          ),
        ),
        backgroundColor: Theme.of(context).accentColor,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              top: 24.0,
              right: 24.0,
            ),
            child: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'CARD DETAILS',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        connectToStripe(null);
                      },
                      child: const Text(
                        '+ Add New',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 20);
                  },
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: cards.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        connectToStripe(cards[index]['paymentMethodId']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5))),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    cards[index]['cardNo'],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'ProximaNova',
                                      color: Colors.black,
                                    ),
                                  ),
                                  checkCardType(cards[index]['cardType']),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'EXPIRY DATE: ',
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    cards[index]['expiryDate'],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon checkCardType(card) {
    switch (card) {
      case 'master':
        return Icon(
          Icons.map,
          size: 24,
        );
      case 'visa':
        return Icon(
          Icons.credit_card,
          size: 24,
        );
      default:
        return Icon(
          Icons.credit_card,
          size: 24,
        );
    }
  }
}
