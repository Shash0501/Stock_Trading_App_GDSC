Map<String, int> resolutionMap = {
  "1": 1,
  "5": 5,
  "15": 15,
  "30": 30,
  "60": 60,
  "D": 24 * 60,
  "W": 24 * 60 * 7,
  "M": 24 * 60 * 28,
};

Map<String, String> resolutionMap2 = {
  "1m": "1",
  "5m": "5",
  "15m": "15",
  "30m": "30",
  "1h": "60",
  "1w": "W",
  "1M": "M",
  "1d": "D"
};

Map<String, String> resolutionMap3 = {
  "1": "1m",
  "5": "5m",
  "15": "15m",
  "30": "30m",
  "60": "1h",
  "W": "1w",
  "M": "1M",
  "D": "1d"
};
List<String> resolutionList = const [
  "1m",
  "5m",
  "15m",
  "30m",
  "1h",
  "1w",
  "1M",
  "1d"
];
