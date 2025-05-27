
qui gen WeekEnd = 0
qui gen Day=dow(Datum)
qui replace WeekEnd = 1 if (Day==0) /* Sunday */
qui replace WeekEnd = 1 if (Day==6) /* Sunday */

qui gen HoliDay = 0

include `defs_path'/defs_SkipDates
foreach sdi of local SKIP_DATES_spaces {
    disp(`sdi')
    *display( floor(`sdi'/10000))
    scalar jahr= floor(`sdi'/10000)
    *display(scalar(jahr))
    scalar monat=floor(( `sdi'-10000*jahr)/100)
    *display(scalar(monat))
    scalar tag  =floor(( `sdi'-10000*jahr-100*monat))
    scalar zeitd = mdy(scalar(monat),scalar(tag),scalar(jahr))
    display(scalar(zeitd))

    qui replace HoliDay = 1 if(Datum==scalar(zeitd))
}

qui drop if WeekEnd == 1
qui drop if HoliDay == 1
qui drop WeekEnd HoliDay
