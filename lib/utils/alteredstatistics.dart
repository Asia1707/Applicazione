// Altero le statistiche per simulare l'effetto dell'alcol sul sonno e sul battito cardiaco a riposo (RHR)

class AlteredStatistics {

  static const int sleepDecrease = 10;      // In MENO sul totale sonno
  static const int wakeIncrease = 4;        // in PIU' sul tempo svegli
  static const int efficiencyDecrease = 1;  // in MENO sull'efficacy (percentuale)
  static const double rhrIncrease = 2.6;    // in PIU' sul RHR

  // RHR (Resting Heart Rate)
  static double calculateModifiedRHR(double originalRHR, bool hasConsumedAlcohol) {
    if (!hasConsumedAlcohol) return originalRHR; // Se non ha bevuto, il dato reale passa intatto
    return originalRHR + rhrIncrease; // Se ha bevuto, somma la penalità al battito
  }

  // MinutesAsleep
  static int calculateModifiedMinutesAsleep(int originalMinutes, bool hasConsumedAlcohol) {
    if (!hasConsumedAlcohol) return originalMinutes; 
    int newMinutes = originalMinutes - sleepDecrease; // Sottrae la penalità di sonno
    return newMinutes < 0 ? 0 : newMinutes; // Impedisco che scendano sotto lo zero
  }

  // MinutesAwake
  static int calculateModifiedMinutesAwake(int originalMinutes, bool hasConsumedAlcohol) {
    if (!hasConsumedAlcohol) return originalMinutes; 
    return originalMinutes + wakeIncrease; 
  }

  // Efficiency
  static int calculateModifiedEfficiency(int originalEfficiency, bool hasConsumedAlcohol) {
    if (!hasConsumedAlcohol) return originalEfficiency; 
    int newEfficiency = originalEfficiency - efficiencyDecrease; 
    return newEfficiency < 0 ? 0 : newEfficiency; // Impedisco scenda sotto lo zero
  }
}