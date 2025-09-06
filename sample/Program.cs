var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("DBConnectionString");
var app = builder.Build();

app.MapGet("/", () => $"Hello World! {connectionString}<br/> Vamos a la pisina con esto");

app.Run();
