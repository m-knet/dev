using Dev.Samples.Grpc.Contracts;
using Microsoft.Extensions.DependencyInjection;
using Polly;
using Polly.Extensions.Http;
using System;
using System.Net;
using System.Net.Http;
using System.Net.Mail;
using System.Threading.Tasks;

namespace Dev.Samples.Grpc.Client
{
    public static class Program
    {
        public static async Task Main()
        {
            SendEmail();
            var services = AddServices();
            var serviceProvider = services.BuildServiceProvider();

            using var scope = serviceProvider.CreateScope();

            var client = scope.ServiceProvider.GetRequiredService<Greeter.GreeterClient>();

            var response = await client.SayHelloAsync(new HelloRequest
            {
                Name = "World"
            });

            Console.WriteLine(response.Message);
        }

        private static ServiceCollection AddServices()
        {
            var services = new ServiceCollection();
            services.AddGrpcClient<Greeter.GreeterClient>(c =>
            {
                c.Address = new Uri("https://localhost:5001");
            })
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            return services;
        }

        private static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy() => HttpPolicyExtensions
            .HandleTransientHttpError()
            .OrResult(msg => msg.StatusCode == System.Net.HttpStatusCode.NotFound)
            .WaitAndRetryAsync(6, retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));

        private static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy() => HttpPolicyExtensions
            .HandleTransientHttpError()
            .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));

        public static string SendEmail()
        {

            try
            {
                // Credentials
                var credentials = new NetworkCredential("", "");
                // Mail message
                var mail = new MailMessage()
                {
                    From = new MailAddress(""),
                    Subject = "Email Sender App",
                    Body = "Body"
                };
                mail.IsBodyHtml = true;
                mail.To.Add(new MailAddress(""));
                // Smtp client
                var client = new SmtpClient()
                {
                    Port = 587,
                    DeliveryMethod = SmtpDeliveryMethod.Network,
                    UseDefaultCredentials = false,
                    Host = "smtp.gmail.com",
                    EnableSsl = true,
                    Credentials = credentials
                };
                client.Send(mail);
                return "Email Sent Successfully!";
            }
            catch (System.Exception e)
            {
                return e.Message;
            }
        }
    }
}
