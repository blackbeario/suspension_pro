// Full Suspension Bikes
Map fullSuspension = {
  "bike": "",
  "front_tire_pressure": "",
  "rear_tire_pressure": "",
  "notes": "",
  "suspension_settings": {
    "fork": fullCompressionRebound,
    "shock": fullCompressionRebound
  },
};

Map fullSuspensionWithCompression = {
  "bike": "",
  "front_tire_pressure": "",
  "rear_tire_pressure": "",
  "notes": "",
  "suspension_settings": {
    "fork": compressionRebound,
    "shock": compressionRebound,
  },
};

Map fullSuspensionWithRebound = {
  "bike": "",
  "front_tire_pressure": "",
  "rear_tire_pressure": "",
  "notes": "",
  "suspension_settings": {
    "fork": reboundOnly,
    "shock": reboundOnly,
  },
};

// Hardtails and DirtJumpers
Map hardTailWithFullFork = {
  "bike": "",
  "front_tire_pressure": "",
  "rear_tire_pressure": "",
  "notes": "",
  "suspension_settings": {
    "fork": fullCompressionRebound,
  },
};

Map hardTailWithCompression = {
  "bike": "",
  "front_tire_pressure": "",
  "rear_tire_pressure": "",
  "notes": "",
  "suspension_settings": {
    "fork": compressionRebound,
  },
};

Map hardTailWithRebound = {
  "bike": "",
  "front_tire_pressure": "",
  "rear_tire_pressure": "",
  "notes": "",
  "suspension_settings": {
    "fork": reboundOnly,
  },
};

// Component Options
Map fullCompressionRebound = {
  "sag": "",
  "springRate": "",
  "compression": {"high_speed": "", "low_speed": ""},
  "rebound": {"high_speed": "", "low_speed": ""},
  "volume_spacers": "",
};

Map compressionRebound = {
  "sag": "",
  "springRate": "",
  "compression": "",
  "rebound": "",
};

Map reboundOnly = {
  "sag": "",
  "springRate": "",
  "rebound": "",
};