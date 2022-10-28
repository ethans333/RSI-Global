#include <NewCandleTime.mqh>

input int RSI_PERIOD = 14;
input int ADX_PERIOD = 4;
input int RSI_WEAK = 40;
input int RSI_STRONG = 60;

string Currencies[] = {"USD", "EUR", "AUD", "NZD", "GBP", "CAD", "CHF", "JPY"};

int TimeFrames[] = {PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};

void SetValidCurrencies (string Currency, string &ValidCurrencies[]) {

   int j = 0;

   for (int i = 0; i < ArraySize(Currencies); i++) {
      
      double x = iRSI(StringConcatenate(Currency, Currencies[i]), 0, 10, 0, 0);
      
      if (x != 0) {
         
         ArrayResize(ValidCurrencies, j+1);
         
         ValidCurrencies[j] = Currencies[i];
         
         j++;
      }
   }
}

int StrengthState (string Currency, string &ValidCurrencies[]) {
   
   int nStrong = 0;
   int nWeak = 0;

   for (int i = 0; i < ArraySize(TimeFrames); i++) {
      for (int j = 0; j < ArraySize(ValidCurrencies); j++) {
         double Strength = iRSI(StringConcatenate(Currency, ValidCurrencies[j]), TimeFrames[i], RSI_PERIOD, PRICE_CLOSE, 0);
         
         if (Strength >= RSI_STRONG) {
            nStrong++;
         } else if (Strength <= RSI_WEAK) {
            nWeak++;
         }
      }
   }
   
   if (nStrong == ArraySize(ValidCurrencies)) {
      return 1;
   } else if (nWeak == ArraySize(ValidCurrencies)) {
      return -1;
   }
   
   return 0;
}

string FindPair (string Currency, string &ValidCurrencies[], int &Signal) {
   
   SetValidCurrencies(Currency, ValidCurrencies);
   
   int StrengthState = StrengthState(Currency, ValidCurrencies);
   
   string ValidCurrenciesOfPair[];
   int StrengthStatePair;
   
   int i = 0;
   
   if (StrengthState == 1) {
      for (i = 0; i < ArraySize(ValidCurrencies); i++) {
         
         SetValidCurrencies(ValidCurrencies[i], ValidCurrenciesOfPair);
      
         StrengthStatePair = StrengthState(ValidCurrencies[i], ValidCurrenciesOfPair);
         
         if (StrengthStatePair == -1) {
            Signal = 1;
            
            Print("BUY");
         
            return StringConcatenate(Currency, ValidCurrencies[i]);
         }
      }
   } else if (StrengthState == -1) {
      for (i = 0; i < ArraySize(ValidCurrencies); i++) {
         
         SetValidCurrencies(ValidCurrencies[i], ValidCurrenciesOfPair);
      
         StrengthStatePair = StrengthState(ValidCurrencies[i], ValidCurrenciesOfPair);
         
         if (StrengthStatePair == 1) {
         
            Signal = -1;
         
            return StringConcatenate(Currency, ValidCurrencies[i]);
         }
      }
   }
   
   Signal = 0;
   
   return "";
   
}

void OnTick () {

   if(IsNewCandle()){
   for (int i = 0; i < ArraySize(Currencies); i++) {
      string Currency = Currencies[i];
   
      string ValidCurrencies[];
      int Signal;
      
      string Pair = FindPair(Currency, ValidCurrencies, Signal);
      
      if (Signal != 0) Print("Testing: ", Currency, ", ", Pair, ", Signal: ", Signal);
      }
   }
}
