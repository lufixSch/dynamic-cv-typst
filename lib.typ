#let information = state("information", (
  personal: (),
))

// Define default configuration for the CV
#let config = state("config", (
  title: "",
  keywords: (
    the: "",
    since: "",
    name: "",
    address: "",
    phone: "",
    email: "",
    birthdate: "",
    birthplace: "",
    citizenship: "",
    gender: "",
  ),
  date_format: "",
))

// Define translations for different languages
#let config_translations = (
  de: (
    title: "Lebenslauf",
    keywords: (
      since: "Seit",
      name: "Name",
      address: "Anschrift",
      phone: "Telefon",
      email: "E-Mail",
      birthdate: "Geburtsdatum",
      birthplace: "Geburtsort",
      citizenship: "Staatsangehörigkeit",
      gender: "Geschlecht",
    ),
    date_format: "[day].[month].[year repr:last_two]",
  ),
  en: (
    title: "Resume",
    keywords: (
      the: "the",
      since: "Since",
      name: "Name",
      address: "Address",
      phone: "Phone",
      email: "E-Mail",
      birthdate: "Date of birth",
      birthplace: "Place of Birth",
      citizenship: "Citizenship",
      gender: "Gender",
    ),
    date_format: "[month repr:short] [day], [year]",
  ),
)

// Define the main function to generate CV
#let cv(
  body,
  paths: (
    personal: "personal.yaml",
  ),
  cfg: config_translations.en,
  columns: (1fr, 3fr),
  lang: "en",
) = {
  // Update information state with data from YAML files
  if paths.at("personal", default: none) == none {
    panic("Personal Information YAML is required!")
  }

  let info = (:)
  for (name, path) in paths.pairs() {
    info.insert(name, yaml(path))
  }
  information.update(info)

  // Update configuration with any provided overwrites
  config.update(c => cfg)

  // Set basic document properties
  set document(
    author: info.personal.name,
    title: cfg.title,
  )

  set page(
    margin: (x: 1cm, y: 1.5cm),
    numbering: "1",
    number-align: right,
  )

  // Set text and paragraph properties
  set text(lang: lang)
  set par(first-line-indent: 0pt, spacing: .7em, justify: true)

  // Set base configuration for tables
  set table(columns: columns, stroke: none, inset: (x: 0pt, y: 5pt))

  // Render the body of the CV
  body
}

// Function to format date range or single date
#let get_date(date) = {
  if type(date) == str {
    return date
  }

  if date.at("end", default: none) == none {
    return [#context { config.get().keywords.since } #date.start]
  }

  return [#date.start - #date.end]
}

// Place profile picture pass to `personal_table` with custom parameters
#let profile(offset: (x: 0pt, y: 0pt), dheight: 0pt, tab_sz, path) = {
  return place(
    top + right,
    dx: tab_sz.width - offset.x,
    dy: -tab_sz.height - 0.5em + offset.y,
    image(
      path,
      height: tab_sz.height + dheight,
    ),
  )
}

// Create a table for personal information
#let personal_table(cfg, info, profile_func) = {
  block({
    let info_tab = table(
      ..if info.at("name", default: none) != none {
        ([#cfg.name:], info.name)
      },
      ..if info.at("address", default: none) != none {
        ([#cfg.address:], info.address)
      },
      ..if info.at("phone", default: none) != none {
        ([#cfg.phone:], info.phone)
      },
      ..if info.at("email", default: none) != none {
        ([#cfg.email:], info.email)
      },
      ..if info.at("birthdate", default: none) != none {
        ([#cfg.birthdate:], info.birthdate)
      },
      ..if info.at("birthplace", default: none) != none {
        ([#cfg.birthplace:], info.birthplace)
      },
      ..if info.at("citizenship", default: none) != none {
        ([#cfg.citizenship:], info.citizenship)
      },
      ..if info.at("gender", default: none) != none {
        ([#cfg.gender:], info.gender)
      }
    )
    info_tab

    if (info.at("picture", default: none) != none and profile_func != none) {
      layout(size => {
        let tab_sz = measure(width: size.width, info_tab)

        profile_func(tab_sz, info.picture)
      })
    }
  })
}

// Create a table for timeline information
#let timeline_table(cfg, info) = {
  table(
    ..for i in info.rev() {
      (
        get_date(i.date),
        [#strong(i.title) #linebreak() #i.at(
            "description",
            default: "",
          )],
      )
    }
  )
}

// Create tables for categorized information
#let category_table(cfg, info) = {
  for c in info {
    if type(c.items) == str {
      set block(spacing: 2pt)
      table(
        strong(c.category),
        c.items,
      )
    } else {
      set block(spacing: 5pt)
      strong(c.category)
      table(
        ..for i in c.items {
          (
            i.name,
            i.description,
          )
        }
      )
    }
  }
}

// Create a signature block
#let signature(place, name, cfg, len: 5cm) = {
  v(1.5cm)
  grid(
    columns: (1fr, 1fr),
    [#place, #datetime.today().display(cfg.date_format)],
    [
      #box(height: 1em, line(start: (0pt, 1em), end: (len, 1em)))\
      #box(
        inset: (x: 5pt, y: 0pt),
        name,
      )],
  )
}
