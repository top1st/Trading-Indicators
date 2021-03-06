#include <WinUser32.mqh>
#define  CHART_CMD_UPDATE_DATA            33324
#define  HEADER_BYTE                        129
#define  DATA_BYTE                           44

#property indicator_separate_window
#property indicator_buffers 8

extern int RefreshTime = 5; //RefreshTime 更新頻度(秒)
extern int MaxBars = 1000;
extern int MAPeriod = 1;
extern int MAPrice = 0;
extern int MAMethod = 0;
extern string Start_Time = "2011.03.14 00:00";
extern bool UseLongTermMode = FALSE;
extern int TimeOffset = 0;
extern int DaySpan = 1;
extern int SelectedLineWidth = 1;
extern int NonSelectedLineWidth = 1;
extern bool UseAutoDetect = TRUE;

bool UseUSD = TRUE;
bool UseEUR = TRUE;
bool UseGBP = TRUE;
bool UseCHF = TRUE;
bool UseJPY = TRUE;
bool UseAUD = TRUE;
bool UseCAD = TRUE;
bool UseNZD = TRUE;

extern bool ShowUSD = TRUE;
extern bool ShowEUR = TRUE;
extern bool ShowGBP = TRUE;
extern bool ShowCHF = TRUE;
extern bool ShowJPY = TRUE;
extern bool ShowAUD = TRUE;
extern bool ShowCAD = TRUE;
extern bool ShowNZD = TRUE;

extern color Color_USD = Orange;
extern color Color_EUR = Red;
extern color Color_GBP = Lime;
extern color Color_CHF = Snow;
extern color Color_JPY = Turquoise;
extern color Color_AUD = RoyalBlue;
extern color Color_CAD = Yellow;
extern color Color_NZD = LightPink;

string sEURUSD;
string sUSDJPY;
string sUSDCHF;
string sGBPUSD;
string sAUDUSD;
string sUSDCAD;
string sNZDUSD;

double EURAV[];
double USDAV[];
double JPYAV[];
double CHFAV[];
double GBPAV[];
double AUDAV[];
double CADAV[];
double NZDAV[];

string Indicator_Name = " EUR USD JPY  CHF GBP AUD CAD NZD";
int Objs = 0;
int Pairs = 8;
bool Gi_420 = FALSE;
int t2 = 0;
int Gi_428 = 0;

int init() {
   string LLK;
   int LEND;
   SetIndexStyle(0, DRAW_LINE, EMPTY, GetWidth("EUR"), Color_EUR);
   SetIndexBuffer(0, EURAV);
   SetIndexLabel(0, "EUR");
   SetIndexStyle(1, DRAW_LINE, EMPTY, GetWidth("USD"), Color_USD);
   SetIndexBuffer(1, USDAV);
   SetIndexLabel(1, "USD");
   SetIndexStyle(2, DRAW_LINE, EMPTY, GetWidth("JPY"), Color_JPY);
   SetIndexBuffer(2, JPYAV);
   SetIndexLabel(2, "JPY");
   SetIndexStyle(3, DRAW_LINE, EMPTY, GetWidth("CHF"), Color_CHF);
   SetIndexBuffer(3, CHFAV);
   SetIndexLabel(3, "CHF");
   SetIndexStyle(4, DRAW_LINE, EMPTY, GetWidth("GBP"), Color_GBP);
   SetIndexBuffer(4, GBPAV);
   SetIndexLabel(4, "GBP");
   SetIndexStyle(5, DRAW_LINE, EMPTY, GetWidth("AUD"), Color_AUD);
   SetIndexBuffer(5, AUDAV);
   SetIndexLabel(5, "AUD");
   SetIndexStyle(6, DRAW_LINE, EMPTY, GetWidth("CAD"), Color_CAD);
   SetIndexBuffer(6, CADAV);
   SetIndexLabel(6, "CAD");
   SetIndexStyle(7, DRAW_LINE, EMPTY, GetWidth("NZD"), Color_NZD);
   SetIndexBuffer(7, NZDAV);
   SetIndexLabel(7, "NZD");
   
   
   if (!ShowEUR) SetIndexStyle(0, DRAW_NONE);
   if (!ShowUSD) SetIndexStyle(1, DRAW_NONE);
   if (!ShowJPY) SetIndexStyle(2, DRAW_NONE);
   if (!ShowCHF) SetIndexStyle(3, DRAW_NONE);
   if (!ShowGBP) SetIndexStyle(4, DRAW_NONE);
   if (!ShowAUD) SetIndexStyle(5, DRAW_NONE);
   if (!ShowCAD) SetIndexStyle(6, DRAW_NONE);
   if (!ShowNZD) SetIndexStyle(7, DRAW_NONE);
   
   if (!UseEUR) Color_EUR = DimGray;
   if (!UseUSD) Color_USD = DimGray;
   if (!UseJPY) Color_JPY = DimGray;
   if (!UseCHF) Color_CHF = DimGray;
   if (!UseGBP) Color_GBP = DimGray;
   if (!UseAUD) Color_AUD = DimGray;
   if (!UseCAD) Color_CAD = DimGray;
   if (!UseNZD) Color_NZD = DimGray;  
   
   Pairs = 7;
   if (!UseEUR) Pairs--;
   if (!UseUSD) Pairs--;
   if (!UseJPY) Pairs--;
   if (!UseCHF) Pairs--;
   if (!UseGBP) Pairs--;
   if (!UseAUD) Pairs--;
   if (!UseCAD) Pairs--;
   if (!UseNZD) Pairs--;
   if (Pairs < 1) Alert("Pairs is ", Pairs);
   SetLevelValue(0, 0);
   IndicatorShortName(Indicator_Name);
   IndicatorDigits(0);
   if (!UseAutoDetect) {
      sEURUSD = "EURUSD";
      sUSDJPY = "USDJPY";
      sUSDCHF = "USDCHF";
      sGBPUSD = "GBPUSD";
      sAUDUSD = "AUDUSD";
      sUSDCAD = "USDCAD";
      sNZDUSD = "NZDUSD";
      
   } else {
      LLK = "";
      LEND = StringLen(Symbol());
      if (LEND > 6) LLK = StringSubstr(Symbol(), 6, LEND - 6);
      sEURUSD = "EURUSD" + LLK;
      sUSDJPY = "USDJPY" + LLK;
      sUSDCHF = "USDCHF" + LLK;
      sGBPUSD = "GBPUSD" + LLK;
      sAUDUSD = "AUDUSD" + LLK;
      sUSDCAD = "USDCAD" + LLK;
      sNZDUSD = "NZDUSD" + LLK;
      
   }
   if (DaySpan < 1) DaySpan = 1;
   if (DaySpan > 31) DaySpan = 31;
   
   
   Objs = 0;
   int cur = 0;
   int st = 23;
   sl("~", cur, Color_EUR);
   cur += st;
   sl("~", cur, Color_USD);
   cur += st;
   sl("~", cur, Color_JPY);
   cur += st;
   sl("~", cur, Color_CHF);
   cur += st;
   sl("~", cur, Color_GBP);
   cur += st;
   sl("~", cur, Color_AUD);
   cur += st;
   sl("~", cur, Color_CAD);
   cur += st;
   sl("~", cur, Color_NZD);
   cur += st;
      
   return (0);
}

void sl(string sym, int Ai_8, color A_color_12) {
   int window_16 = WindowFind(Indicator_Name);
   string name_20 = Indicator_Name + Objs;
   Objs++;
   if (A_color_12 < Black) A_color_12 = 2147483647;
   ObjectCreate(name_20, OBJ_LABEL, window_16, 0, 0);
   ObjectSet(name_20, OBJPROP_XDISTANCE, Ai_8 + 6);
   ObjectSet(name_20, OBJPROP_YDISTANCE, 0);
   ObjectSetText(name_20, sym, 18, "Arial Black", A_color_12);
}

int deinit() {
   ObjectDelete("Period_Base");
   return (0);
}

int GetWidth(string As_0) {
   int Li_8 = StringFind(Symbol(), As_0);
   if (Li_8 == -1) return (NonSelectedLineWidth);
   return (SelectedLineWidth);
}

double GetVal(string sym1, int Ai_8, int Ai_12) {
   double ima_16 = iMA(sym1, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym1, 0, Ai_8));
   double ima_24 = iMA(sym1, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym1, 0, Ai_12));
   if (ima_24 == 0.0) return (0);
   return (10000.0 * MathLog(ima_16 / ima_24));
}

   double f0_4(string sym1, string sym2, int t1, int t2) {
   double V1 = iMA(sym1, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym1, 0, t1));
   double V2 = iMA(sym1, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym1, 0, t2));
   V1 *= iMA(sym2, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym2, 0, t1));
   V2 *= iMA(sym2, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym2, 0, t2));
   if (V2 == 0.0) return (0);
   return (100.0 * MathLog(V1 / V2));
}

   double f0_0(string sym1, string sym2, int t1, int t2) {
   double V1 = iMA(sym1, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym1, 0, t1));
   double V2 = iMA(sym1, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym1, 0, t2));
   double V3 = iMA(sym2, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym2, 0, t1));
   double V4 = iMA(sym2, 0, MAPeriod, 0, MAMethod, MAPrice, iBarShift(sym2, 0, t2));
   if (V3 == 0.0) return (0);
   if (V4 == 0.0) return (0);
   V1 /= V3;
   V2 /= V4;
   if (V2 == 0.0) return (0);
   return (100.0 * MathLog(V1 / V2));
}

   int start() {
   EventSetTimer(RefreshTime);
   double EURUSD,USDJPY,USDCHF,GBPUSD,AUDUSD,USDCAD,NZDUSD,a;
   datetime t1;
   if (!Gi_420) init();
   Gi_420 = TRUE;
   int ind_counted_232 = IndicatorCounted();
   int Li_236 = MathMin(MaxBars, Bars);
   if (Gi_428 != 0) Li_236 = MathMin(Li_236, Bars - ind_counted_232 + 1);
   if (Li_236 >= 1) {
      for (int i = Li_236; i >= 0; i--) {
         t1 = Time[i];
         t2 = MathFloor((Time[i] + 60 * (60 * TimeOffset)) / (86400 * DaySpan)) * (86400 * DaySpan) - 60 * (60 * TimeOffset);
         if (TimeDayOfWeek(t2) == 0) t2 -= 172800;
         if (UseLongTermMode) {
            t2 = StrToTime(Start_Time);
            ObjectCreate("Period_Base", OBJ_VLINE, 0, t2, 0);
            ObjectSetText("Period_Base", "StartTime");
            ObjectSet("Period_Base", OBJPROP_COLOR, Aqua);
            ObjectSet("Period_Base", OBJPROP_WIDTH, 1);
         }
         if (t1 == t2) {
            EURAV[i] = EMPTY_VALUE;
            USDAV[i] = EMPTY_VALUE;
            JPYAV[i] = EMPTY_VALUE;
            CHFAV[i] = EMPTY_VALUE;
            GBPAV[i] = EMPTY_VALUE;
            AUDAV[i] = EMPTY_VALUE;
            CADAV[i] = EMPTY_VALUE;
            NZDAV[i] = EMPTY_VALUE;
            
         } else {
            EURUSD = GetVal(sEURUSD, t1, t2);
            USDJPY = GetVal(sUSDJPY, t1, t2);
            USDCHF = GetVal(sUSDCHF, t1, t2);
            GBPUSD = GetVal(sGBPUSD, t1, t2);
            AUDUSD = GetVal(sAUDUSD, t1, t2);
            USDCAD = GetVal(sUSDCAD, t1, t2);
            NZDUSD = GetVal(sNZDUSD, t1, t2);
                    
            if (!UseNZD) {NZDUSD = 0;}
            if (!UseCAD) {USDCAD = 0;}
            if (!UseCHF) {USDCHF = 0;}
            if (!UseAUD) {AUDUSD = 0;}
            if (!UseEUR) {EURUSD = 0;}
            if (!UseUSD) {EURUSD = 0; USDJPY = 0; USDCHF = 0; GBPUSD = 0; AUDUSD = 0; USDCAD = 0; NZDUSD = 0;}
            if (!UseJPY) {USDJPY = 0;}
            if (!UseGBP) {GBPUSD = 0;}
            
            a = (EURUSD + GBPUSD + AUDUSD + NZDUSD - USDJPY - USDCHF - USDCAD) / 7;
            
      EURAV[i]= EURUSD - a ;
      USDAV[i]= - a ;
      JPYAV[i]= -USDJPY - a ;
      CHFAV[i]= -USDCHF - a ;
      GBPAV[i]= GBPUSD - a ;      
      AUDAV[i]= AUDUSD - a ;
      CADAV[i]= -USDCAD - a ;
      NZDAV[i]= NZDUSD - a ;
      
         }
      }
      return (0);
   }
}
