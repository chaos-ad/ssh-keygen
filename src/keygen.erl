-module(keygen).
-compile(export_all).

make_cert(Validity, Name) ->
    make_cert(undefined, Validity, Name).

make_cert(Issuer, Validity, Name) ->
    make_cert(Issuer, Validity, Name, "RU", "Moscow", "NoName", "NoName", "chaos-ad@yandex.ru").

make_cert(undefined, Validity, Name, Country, City, Org, OrgUnit, EMail) ->
    io:format("Generating '~s' certificate...~n", [Name]),
    Subject = [{name, Name},{country,Country},{city,City},{org,Org},{org_unit,OrgUnit},{email,EMail}],
    Options = [{validity,Validity},{subject,Subject}],
    erl_make_certs:make_cert(Options);

make_cert(Issuer, Validity, Name, Country, City, Org, OrgUnit, EMail) ->
    io:format("Generating '~s' certificate...~n", [Name]),
    Subject = [{name, Name},{country,Country},{city,City},{org,Org},{org_unit,OrgUnit},{email,EMail}],
    Options = [{issuer,Issuer},{validity,Validity},{subject,Subject}],
    erl_make_certs:make_cert(Options).

mkdir(Dir) ->
    file:make_dir(Dir).

write_pem(Dir, Name, Pem) ->
    erl_make_certs:write_pem(Dir, Name, Pem).

del(File) ->
    file:delete(File).

mv(From, To) ->
    file:rename(From, To).

all() ->
    all(filename:dirname(filename:dirname((code:which(?MODULE))))).

all(RootDir) ->
    OutDir  = filename:join([RootDir, "keys"]),
    io:format("Generating keys into directory '~s'...~n", [OutDir]),

    LongTime = calendar:gregorian_days_to_date(calendar:date_to_gregorian_days(date())+15*365),
    Validity = {date(), LongTime},

    RootCA   = make_cert(Validity, "root"),
    ClientCA = make_cert(RootCA, Validity, "client"),
    ServerCA = make_cert(RootCA, Validity, "server"),

    mkdir(OutDir),
    RootPath   = filename:join([OutDir,   "root"]), mkdir(RootPath),
    ClientPath = filename:join([OutDir, "client"]), mkdir(ClientPath),
    ServerPath = filename:join([OutDir, "server"]), mkdir(ServerPath),

    write_pem(RootPath,   "cert", RootCA),
    write_pem(ClientPath, "cert", ClientCA),
    write_pem(ServerPath, "cert", ServerCA),

    del(filename:join(RootPath,   "cert_key.pem")),
    mv(filename:join(ClientPath, "cert_key.pem"), filename:join(ClientPath, "key.pem")),
    mv(filename:join(ServerPath, "cert_key.pem"), filename:join(ServerPath, "key.pem")),

    io:format("ok~n"),
    ok.