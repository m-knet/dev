using System.Threading.Tasks;
using Grpc.Core;
using Microsoft.Extensions.Logging;
using Dev.Samples.Grpc.Contracts;

namespace Dev.Samples.Grpc
{
    public class GreeterService : Greeter.GreeterBase
    {
        private readonly ILogger<GreeterService> _logger;
        public GreeterService(ILogger<GreeterService> logger)
        {
            _logger = logger;
        }

        public override Task<HelloReply> SayHello(HelloRequest request, ServerCallContext context)
        {
            throw new RpcException(new Status(StatusCode.AlreadyExists, "Testing"));
            ////return Task.FromResult(new HelloReply
            ////{
            ////    Message = "Hello " + request.Name
            ////});
        }
    }
}
