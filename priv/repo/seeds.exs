alias HeadsUp.Repo
alias HeadsUp.Incidents.Incident

%Incident{
  name: "Lost Dog",
  description: "A friendly dog is wandering around the neighborhood. 🐶",
  priority: 2,
  status: :pending,
  image_path: "/images/lost-dog.jpg"
}
|> Repo.insert!()

%Incident{
  name: "Flat Tire",
  description: "Our beloved ice cream truck has a flat tire! 🛞",
  priority: 1,
  status: :resolved,
  image_path: "/images/flat-tire.jpg"
}
|> Repo.insert!()

%Incident{
  name: "Bear In The Trash",
  description: "A curious bear is digging through the trash! 🐻",
  priority: 1,
  status: :canceled,
  image_path: "/images/bear-in-trash.jpg"
}
|> Repo.insert!()
