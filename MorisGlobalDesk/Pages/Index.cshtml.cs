using Microsoft.AspNetCore.Mvc.RazorPages;

namespace MorisGlobalDesk.Pages;

public class IndexModel : PageModel
{
    public DateTime MauritianTime { get; private set; }
    public DateTime UkTime { get; private set; }
    public int HoursAheadOfUk { get; private set; }
    
    public void OnGet()
    {
        DateTime utcTime = DateTime.UtcNow;
        
        MauritianTime = GetMauritianTime(utcTime);

        UkTime = GetUkTime(utcTime);

        var differenceBetweenUkAndMauritius = DifferenceBetweenUkAndMauritius();
        HoursAheadOfUk = differenceBetweenUkAndMauritius;
    }

    private int DifferenceBetweenUkAndMauritius()
    {
        int differenceBetweenUkAndMauritius = (int)(MauritianTime - UkTime).TotalHours;
        return differenceBetweenUkAndMauritius;
    }

    private DateTime GetMauritianTime(DateTime utcTime)
    {
        TimeZoneInfo timeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById("Mauritius Standard Time");
        return TimeZoneInfo.ConvertTimeFromUtc(utcTime, timeZoneInfo);
    }

    private DateTime GetUkTime(DateTime utcTime)
    {
        TimeZoneInfo timeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById("GMT Standard Time");
        return TimeZoneInfo.ConvertTimeFromUtc(utcTime, timeZoneInfo);
    }
}