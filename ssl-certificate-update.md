---
layout: default
title: SSL Certificate Update
url: /ssl-certificate-update
previous: /security
next: /patterns
---

# SSL Certificate Updates

**UPDATE 2016-10-06**: RubyGems 2.6.7 has been released.
Always make sure you download the latest released version.

**UPDATE 2014-12-21**: RubyGems 1.8.30, 2.0.15, and 2.2.3 have been released.
It requires manual installation, please see instructions [below](#installing-using-update-packages).

---

Hello,

If you reached this page, means you've hit this SSL error when trying to
pull updates from RubyGems:

    SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed

This error is produced by changes in rubygems.org infrastructure, you can read the
[background below](#background).
Please follow the instructions below to update your rubygems:

## Installing using update packages

Now that RubyGems 2.6.x has been released, you can manually update to this version.

Download [rubygems-update-2.6.7.gem](https://rubygems.org/downloads/rubygems-update-2.6.7.gem)

Please download the file in a directory that you can later point to (eg. the
root of your harddrive `C:\`)

Now, using your Command Prompt:

```
C:\>gem install --local C:\rubygems-update-2.6.7.gem
C:\>update_rubygems --no-ri --no-rdoc
```

After this, `gem --version` should report the new update version.

You can now safely uninstall `rubygems-update` gem:

```
C:\>gem uninstall rubygems-update -x
Removing update_rubygems
Successfully uninstalled rubygems-update-2.6.7
```

## Background

For those who are not familiar with SSL and certificates, there are many
parts that make secure serving of content possible.

SSL certificates are used on the website, which are obtained from a
certificate authority (CA) and generated from a private key, along with its
respective signature.

Normally and up until a few months ago, private key signatures used SHA-1
as way to provide a digest (or checksum) of the private key without
distributing the key itself (remember, needs to remain private).

SHA-1 has been encountered weak and lot of web servers and sites have been
upgrading towards SHA-2 (specifically SHA256 or higher) in order to prepare
for the browsers changes.

## Specific problem with RubyGems

The particular case of RubyGems (the command line tool) is that it requires
to bundle inside of its code the trust certificates, which allow RubyGems
to establish a connection with the servers even when base operating system
is unable to verify the identity of them.

Up until a few months ago, this certificate was provided by one CA, but
newer certificate is provided by a different one.

Because of this, existing installations of RubyGems would have to been
updated before the switch of the certificate and give enough time for the
change to spread (and people to update).

As what normally happens with software, things might get out of sync and
coordinate such effort, to the size and usage of rubygems.org is almost
impossible.

I've described this on [Issue #1050](https://github.com/rubygems/rubygems/issues/1050#issuecomment-61422934)

We had discussed also on IRC, and patches and backports were provided to
all major branches of RubyGems: 1.8, 2.0, 2.2, and 2.4

You can find the commits associated with these changes here:

- [1.8 branch](https://github.com/rubygems/rubygems/commit/74ee66395c8e1b9ad6a45ba2f292bee8c6ea1a50)
- [2.0 branch](https://github.com/rubygems/rubygems/commit/98f5f44c7141881c756003e4256b1a96b200b98e)
- [2.2 branch](https://github.com/rubygems/rubygems/commit/17d8922966051864a0c4bf768623e9d0c854de26)
- [2.4 branch](https://github.com/rubygems/rubygems/commit/5a31f092d483ea7ccd91adbf08a88593cf0fbbc7)
- [2.6 branch](https://github.com/rubygems/rubygems/commit/5ee6a59784b1736553e16fda374c18491bb66abe)

Problem is, only RubyGems 2.4.4 got released, leaving Ruby installation with
1.8, 2.0 and 2.2 in a broken state.

Specially since RubyGems 2.4 is broken on Windows.

Please understand this could happen to anyone. Release multiple versions of
*any* software in a short span of time and be very time sensitive is highly
complicated.

Even if we have official releases of any of the versions that correct the
issue, it will not be possible install those via RubyGems (chicken-egg
problem described before).

Once official releases are out, installation might be simpler. In the
meantime, please proceed using the instructions described below.

## Manual solution to SSL issue

If you have read the above detail that describe the issue, thank you.

Now, you want to manually fix the issue with your installation.

Steps are simple:

- Step 1: Obtain the new trust certificate
- Step 2: Locate RubyGems certificate directory in your installation
- Step 3: Copy new trust certificate
- Step 4: Profit

### Step 1: Obtain the new trust certificate

If you've read the previous sections, you will know what this means (and
shame on you if you have not).

We need to download [GlobalSignRootCA.pem](https://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/index.rubygems.org/GlobalSignRootCA.pem).

Use the above link and place/save this file somewhere you can later find
easily (eg. your Desktop).

**IMPORTANT**: File must have `.pem` as extension. Browsers like Chrome will
try to save it as plain text file. Ensure you change the filename to have
`.pem` in it after you have downloaded it.

### Step 2: Locate RubyGems certificate directory in your installation

In order for us copy this file, we need to know where to put it.

Depending on where you installed Ruby, the directory will be different.

Take for example the default installation of Ruby 2.1.5, placed in `C:\Ruby21`

Open a Command Prompt and type in:

```
C:\>gem which rubygems
C:/Ruby21/lib/ruby/2.1.0/rubygems.rb
```

Now, let's locate that directory. From within the same window, enter the path
part up to the file extension, but using backslashes instead:

```
C:\>start C:\Ruby21\lib\ruby\2.1.0\rubygems
```

This will open a Explorer window inside the directory we indicated.

### Step 3: Copy new trust certificate

Now, locate `ssl_certs` directory and copy the `.pem` file we obtained from
previous step inside.

It will be listed with other files like `AddTrustExternalCARoot.pem.`.

### Step 4: Profit

There is actually no step 4. You should be able to install Ruby gems without
issues now.
