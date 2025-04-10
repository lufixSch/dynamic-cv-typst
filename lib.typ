#let information = state("information", (
  personal: (),
  education: [],
  work: [],
  skills: [],
))

#let config = state("config", (
  title: "Resume",
  keywords: (
    since: "Since",
    name: "Name",
    address: "Address",
    phone: "Phone",
    email: "E-Mail",
    birthdate: "Date of birth",
    birthplace: "Place of Birth",
    citizenship: "Citizenship",
    gender: "Gender"
  )
))

#let translations = (
  de: (
    keywords: (
      since: "Seit",
      name: "Name",
      address: "Anschrift",
      phone: "Telefon",
      email: "E-Mail",
      birthdate: "Geburtsdatum",
      birthplace: "Geburtsort",
      citizenship: "Staatsangehörigkeit",
      gender: "Geschlecht"
    )
  )
)

#let cv(
  body,
  paths: (
    personal: "personal.yaml",
    education: "education.yaml",
    work: "work.yaml",
    skills: "skills.yaml",
  ),
  config_overwrite: config,
  columns: (1fr, 3fr),
  lang: "en",
) = {
  information.update(
    i => ( personal: yaml(paths.personal), education: yaml(paths.education), work: yaml(paths.work), skills: yaml(paths.skills))
  )

  config.update(c => config_overwrite)

  context {

  // Basic document properties
  set document(author: information.get().personal.name, title: config.get().title)
  set page(
    margin: (left: 10mm, right: 10mm, top: 10mm, bottom: 10mm),
    numbering: "1",
    number-align: right,
  )

  // Text/Font
  set text(lang: lang)
  set par(first-line-indent: 0pt, spacing: .7em, justify: true)

  }

  // Table base config
  set table(
    columns: columns,
    stroke: none
  )

  body
}


#let get_date(date) = {
  if type(date) == str {
    return date
  }

  if date.at("end", default: none) == none {
    return [#context {config.get().keywords.since} #date.start]
  }

  return [#date.start - #date.end]
}
