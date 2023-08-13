import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/hourly_forecast_item.dart';

import 'additional_info_item.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final apiKey = dotenv.env['WEATHER_API_KEY'];
      const cityName = "Jos";
      final url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName,ng&APPID=$apiKey");
      final response = await http.get(url);
      // print(response.body);
      final res = jsonDecode(response.body);
      if (int.parse(res['cod']) != 200) {
        print(res['message']);
        throw "An unexpected error occurred";
      }
      // temp = res['list'][0]['main']['temp'];
      res['list'][0]['main']['temp'];
      return res;
    } catch (e) {
      // print(e);
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jos Weather App"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          // double temp = snapshot['list'][0]['main']['temp'];
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentData = data['list'][0];
          final currentTemp = currentData['main']['temp'];
          final skyTemp = currentData['weather'][0]['main'];
          final pressure = currentData["main"]['pressure'];
          final windSpeed = currentData["wind"]['speed'];
          final humiditiy = currentData["wind"]['speed'];
          final hourlyForcast = data['list'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main Card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaY: 10,
                          sigmaX: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemp K",
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                skyTemp == "Clouds" || skyTemp == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                skyTemp,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Hourly Forcast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
                ),
                //weather forcast card
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 39; i++)
                //         HourlyForecastItem(
                //           time: hourlyForcast[i + 1]['dt'].toString(),
                //           icon: hourlyForcast[i + 1]['weather'][0]['main'] ==
                //                       "Clouds" ||
                //                   hourlyForcast[i + 1] == "Rain"
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           temp: hourlyForcast[i + 1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final time =
                            DateTime.parse(hourlyForcast[index + 1]['dt_txt']);
                        return HourlyForecastItem(
                          time: DateFormat.Hm().format(time),
                          icon: hourlyForcast[index + 1]['weather'][0]
                                          ['main'] ==
                                      "Clouds" ||
                                  hourlyForcast[index + 1] == "Rain"
                              ? Icons.cloud
                              : Icons.sunny,
                          temp: hourlyForcast[index + 1]['main']['temp']
                              .toString(),
                        );
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
                //additional information
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AdditionalItems(
                      icon: Icons.water_drop,
                      title: "Humidity",
                      degree: humiditiy.toString(),
                    ),
                    AdditionalItems(
                        icon: Icons.air,
                        title: "Wind Speed",
                        degree: windSpeed.toString()),
                    AdditionalItems(
                        icon: Icons.beach_access,
                        title: "Pressure",
                        degree: pressure.toString()),
                  ],
                ),
                // const Placeholder(fallbackHeight: 150)
              ],
            ),
          );
        },
      ),
    );
  }
}
