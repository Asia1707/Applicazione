class AlteredStatistics {

  static const int sleepDecrease = 10;      // In MENO sul totale sonno
  static const int wakeIncrease = 4;        // in PIU' sul tempo svegli
  static const int efficiencyDecrease = 1;  // in MENO sull'efficacy (percentuale)
  static const double rhrIncrease = 2.6;    // in PIU' sul RHR

  // RHR
  static double calculateModifiedRHR(double originalRHR, bool hasConsumedAlcohol) {
    if (!hasConsumedAlcohol) return originalRHR;
    return originalRHR + rhrIncrease;
  }

  // MinutesAsleep
  static int calculateModifiedMinutesAsleep(int originalMinutes, bool hasConsumedAlcohol) {
    if (!hasConsumedAlcohol) return originalMinutes;
    int newMinutes = originalMinutes - sleepDecrease;
    return newMinutes < 0 ? 0 : newMinutes; 
  }

  // MinutesAwake
  static int calculateModifiedMinutesAwake(int originalMinutes, bool hasConsumedAlcohol) {
    if (!hasConsumedAlcohol) return originalMinutes;
    return originalMinutes + wakeIncrease;
  }

  //Efficiency
  static int calculateModifiedEfficiency(int originalEfficiency, bool hasConsumedAlcohol) {
    if (!hasConsumedAlcohol) return originalEfficiency;
    int newEfficiency = originalEfficiency - efficiencyDecrease;
    return newEfficiency < 0 ? 0 : newEfficiency; 
  }
}