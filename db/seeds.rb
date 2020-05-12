# This file should contain all the record creation needed to seed the database
# with its default values.  The data can then be loaded with the rails db:seed
# command (or created alongside the database with db:setup).

fb_users = [
  {
    sno: 3,
    uid: '149666409912976',
    name: 'Tanner Blumer',
    email: 'blumer.tanner@gmail.com',
    token: 'EAALPZC2ZBEXa8BAMzpFI733iAQj5o55ZBWQZCKPbgNAwUZAjNsmUgllP6aXmA1Uv5zGnmiNEvoXFYzQzwcIi47NDJ4HHjTMbka1pQiHJofsWk4UtpPBZAGTbSNk9H1hLRW0ejsoD0yVL9QQCCsylGelcovnwtVG16ZAQCZAbSWjWUQZDZD',
    ad_account_id: 'act_234778337767773',
    page_id: '104275274587524',
    url: 'https://cablepal-shop.myshopify.com/',
    active: 1
  },
  {
    sno: 9,
    uid: '10213632395639064',
    name: 'Alex Crumpton',
    email: 'alex.john.crumpton@outlook.com',
    token: 'EAALPZC2ZBEXa8BAD4ZCUN9MO3OLdBC4E3kLneLNBRyIa0WcGhqXLiT8JCIKgEJzrNlrAbvshRtLba8hFlTUTteEOdlpQ12Rg23bizHlAAxxMY77uZAy5tcxK7oq56XV8ZCDlpPZCuWeRsHrVVG6Og724eVLIBdI5YZAw2YPXVlJlgZDZD',
    ad_account_id: 'act_2258257991064042',
    page_id: '621941494910454',
    url: 'ecomcashflowmachine.com',
    active: 1
  }
]

fb_users.each do |fb_user|
  # A poem:
  # Arrays start at 0
  # db starts with 1
  # hence index + 1
  FbUser.create(fb_user)
end
