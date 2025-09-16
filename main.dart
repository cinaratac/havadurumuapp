import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:havadurumu/model/weathermodel.dart';

void main(List<String> args) {
  runApp(const havadurumu());
}

class havadurumu extends StatelessWidget {
  const havadurumu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const homepage(),
    );
  }
}

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final List<String> sehirler = [
    "Ankara",
    "Bursa",
    "Kastamonu",
    "İstanbul",
    "Van",
    "Gaziantep",
  ];

  String? secilenSehir;
  Future<WeatherModel>? weatherfuture;

  void selectedcity(String sehir) {
    setState(() {
      secilenSehir = sehir;
      weatherfuture = getWeather(sehir);
    });
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: "https://api.openweathermap.org/data/2.5",
      queryParameters: {
        "appid": "9da5bce384d175aadec98aec56df5ba2",
        "lang": "tr",
        "units": "metric",
      },
    ),
  );

  Future<WeatherModel> getWeather(String secilensehir) async {
    final response = await dio.get(
      "/weather",
      queryParameters: {"q": secilensehir},
    );
    var model = WeatherModel.fromJson(response.data);
    debugPrint(model.name);
    debugPrint(model.main?.temp.toString());
    return model;
  }

  _buildemptycard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: SizedBox(
        height: 182,
        width: 440,
        child: Center(
          child: Text(
            "Şehir seçiniz",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }

  _buildloadingcard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: SizedBox(
        height: 182,
        width: 440,
        child: Column(children: [Center(child: CircularProgressIndicator())]),
      ),
    );
  }

  _buildCardweather(WeatherModel weatherModel) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              weatherModel.name!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 2),
            Text(
              weatherModel.main!.temp!.round().toString() + "°",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(weatherModel.weather?[0].description ?? "Değer bulunamadı"),
            SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(Icons.water_drop),
                    SizedBox(height: 3),
                    Text(weatherModel.main!.humidity!.round().toString()),
                  ],
                ),
                SizedBox(width: 23),
                Column(
                  children: [
                    Icon(Icons.air),
                    SizedBox(height: 3),
                    Text(weatherModel.wind!.speed!.round().toString()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Hava durumu"))),
      body: Column(
        children: [
          FutureBuilder(
            future: weatherfuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                _buildloadingcard();
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.hasData) {
                return _buildCardweather(snapshot.data!);
              }
              return _buildemptycard();
            },
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final isselected = secilenSehir == sehirler[index];
                return GestureDetector(
                  onTap: () => selectedcity(sehirler[index]),
                  child: Card(
                    color: isselected ? Colors.blue.shade200 : null,
                    child: Center(child: Text(sehirler[index])),
                  ),
                );
              },
              itemCount: sehirler.length,
            ),
          ),
        ],
      ),
    );
  }
}
