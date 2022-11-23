
using System.Security.Policy;

namespace Profiles.Edit.Modules.CustomEditMailingAddress
{
    public class MailingAddress
    {
        public MailingAddress() { }

        public MailingAddress(
            string line1, string line2, string city, string state, string zip
        )
        {
            this.Line1 = line1;
            this.Line2 = line2;
            this.City = city;
            this.State = state;
            this.Zip = zip;
        }

        public string Line1 { get; set; }
        public string Line2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Zip { get; set; }

    }
}
